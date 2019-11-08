# META-begin
# This file is part of the Script Installer
# Copyright (C) step, 2019
# License: MIT
# Installer version=1.0.0
# META-end

# Positional parameters
#
# -v FEATURE=N[,M...]  optional - default "0"
#  . Print the following session features (in list order):
#    0(session summary) [-]1(directory creation) [-]2(file backup)
#    [-]3(file copy) 4(basic timedate) 5(basic status)
#  . A negative number outputs items in reverse install order, so 1,2,3
#    unwinds an install session, and -3,-2,-1 unwinds it backwards.
#  . A feature header is printed iff multiple features are requested.
#    Append an extra comma to force the header, e.g. "1,"
#  . A blank line is appended to mark the end of session's features.
#  . Basic features print no header and, if not mixed with non-basic
#    features, also no end line.
#
# -v STATUS=N[,M...]  optional - default "0"
#  . Select only the sessions that have status N or M...:
#    0(installed) 1(did not start) 2(did not finish) 3(uninstalled) *(all)
#

# Tips
#
# Output the last session only:
#   awk -f .../view.awk | awk -v RS= 'END{print}'
#
# The 2nd (nth) session only:
#   awk -f .../view.awk | awk -v RS= '2==NR'  # n==NR
#
# First and third sessions only:
#   awk -f .../view.awk | awk -v RS= '1==NR||3==NR{print;print""}'  # n==NR
#
# Select a session by date and time
#   awk -f -v FEATURE="0," .../view.awk |
#     awk -v RS= '/2019-09-27-10-11-12/'
#
# All sessions in a day:
#     awk -v RS= '/2019-09-27/{print;print""}'

BEGIN {
	FS = "\t"

	if (!FEATURE)  { FEATURE  = "0" }

	# init "status" print regex
	if (!STATUS)  { STATUS  = "0" }
	if ("*" == STATUS) { STATUS="0,1,2,3" }
	if (STATUS) {
		F["status"] = "^\\(("STATUS")\\)"
		gsub(/,/, "|", F["status"])
	} else {
		F["status"] = "."
	}
}

# skip comments
/^#/ { next }

# a session will always have a "start" but it might not have an "end", which
# means an install error occurred

/^[[:digit:]]+\tstart\t/ {
	if (did_not_finish) { # the previous session
		End[session] = --nR
	}
	# start new session
	Start[++session] = ++nR
	# assume the current session did not finish until proved wrong
	did_not_finish = 1
}

/^[[:digit:]]+\tstart\t/, /^[[:digit:]]+\tend$/ {
	R[nR++] = $0

	# gather stats data
	++Stats[session"/"$2]
}

/^[[:digit:]]+\tend$/ {
	End[session] = --nR
	did_not_finish = 0
}

END {
	if (did_not_finish) { # the very last session
		End[session] = --nR
	}

	# show sessions
	for(s = 1; s <= session; s++) {
		delete I
		get_info(s, I)
		if (I["status"] ~ F["status"]) {
			print_features(I)
		}
	}
}

function get_info(session, aA,   i, p, n, X) { # {{{1
	aA["linenum/start"] = Start[session]
	aA["linenum/end"]   = End[session]
	aA["length"]        = aA["linenum/end"] - aA["linenum/start"] +1
	aA["start"]         = R[aA["linenum/start"]   ]
	aA["args"]          = R[aA["linenum/start"] +1]
	aA["test"]          = R[aA["linenum/start"] +2]
	parse_list("start", aA)
	parse_list("args",  aA)
	parse_list("test",  aA)

	parse_stats(session, aA)


	# Fill in session status.
	# Session status in install.log is always "" log except for
	# "3(uninstalled)", which only uninstall.sh can add.
	aA["status"]        = aA["start/STATUS"]
	if ("" == aA["status"]) {
		p = R[aA["linenum/end"]]
		if (p ~ /\ttest\t/) {
			aA["status"] = "(1)did not start"
		} else if (p !~ /\tend$/) {
			aA["status"] = "(2)did not finish"
		} else {
			aA["status"] = "(0)installed"
		}
	}
}

# parse tab-separated list of key"="value pairs {{{1}}}
# provide iter dict"/"i"key" -> key, dict"/"i"value" -> value,
# with i in [1, ..., dict"/count"],
# and also association dict"/"key -> value
function parse_list(dict, aA,   k, v, i, n, p, nX, X) { # {{{1
	nX = split(aA[dict], X, /\t/)
	for(i = 1; i <= nX; i++) {
		if (p = index(X[i], "=")) {
			n = ++aA[dict"/count"]
			aA[dict"/"n, "key"]   = k = substr(X[i], 1, p -1)
			aA[dict"/"n, "value"] = v = substr(X[i], p +1)
			aA[dict"/"k] = v
		}
	}
}

# print parsed list {{{1}}}
# by default empty and NA values and hidden keys aren't printed:
# pass empty_values != 0 to print empty values;
# hidden_keys != 0 to print hidden keys (those that end with "_", e.g., "args/HOME_DIR_");
# NAs != 0 to print NA values;
# DEBUG if fmt starts with "debug" : print aA's keys too.
function print_list(fmt, dict, aA, empty_values, hidden_keys, NAs,   debug, b, i, k, v) { # {{{1
	debug = 1 == index(fmt, "debug")
	for(i = 1; i <= 0 + aA[dict"/count"]; i++) {
		k = aA[dict"/"i, "key"]
		v = aA[dict"/"i, "value"]
		b = "_" == substr(k, length(k)) && !hidden_keys # don't print this hidden key
		b = b || "" == v && !empty_values               # don't print this empty value
		b = b || "NA" == v && !NAs                      # don't print this NA value
		if (!b) {
			printf (debug ?("aA["dict"/"k"] <") :"")fmt"\n", k, v
		}
	}
}

function parse_stats(session, aA,   k, X) { # {{{1
	for(k in Stats) {
		split(k, X, "/")
		if ( session == X[1] ) { aA["stats/"X[2]] = Stats[session"/"X[2]] +0 }
	}
}

function print_stats(fmt, aA) { # {{{1
	printf(fmt, "operations", "")
	printf "file b=%d c=%d m=%d o=%d", aA["stats/bkp-f"], aA["stats/cp-f"], aA["stats/chmod-f"], aA["stats/chown-f"]
	printf " - directory c=%d m=%d o=%d", aA["stats/mkdir"], aA["stats/chmod-d"], aA["stats/chown-d"]
	print ""
}

function print_features(aA,   fmt, i, p, reverse, newline, with_header, nX, X) { # {{{1
	# DEBUG if fmt starts with "debug" : enable debug output
	fmt = "%-20s: %s"
	if (1 == index(fmt, "debug")) { for(i in aA) { print "aA["i"]=("aA[i]")" |"sort"}; close("sort") }
	nX = split(FEATURE, X, /,/)
	with_header = nX > 1
	for(p = 1; p <= nX; p++) {
		if (reverse = "-" == substr(X[p], 1, 1)) {
			X[p] = substr(X[p], 2)
		}
		if ("0" == X[p]) { # 0(session summary)
			newline = 1
			if (with_header) { print_header(aA, "summary") }
			printf fmt"\n", "datetime",   aA["start/DATETIME"]
			printf fmt"\n", "status",     pretty_status(aA["status"])
			# printf fmt"\n", "linenum/start",          aA["linenum/start"]
			# printf fmt"\n", "linenum/end",          aA["linenum/end"]
			# printf fmt"\n", "length",     aA["length"]
			# printf fmt"\n", "line/args",       aA["line/args"]
			# printf fmt"\n", "line/test",       aA["line/test"]
			print_stats(fmt, aA)
			print_list(fmt, "test", aA) # authoritative DEST_DIR
			print_list(fmt, "args", aA) # duplicated DEST_DIR -- keep after
			print_list(fmt, "start", aA)

		} else if ("1" == X[p]) { # 1(directory creation)
			newline = 1
#			if (with_header) { printf "(aA) (%s) (%s) (%s) (%s)\n", "mkdir", aA["stats/mkdir"], aA["test/DEST_DIR"], aA["test/HOME_DIR"] } #XXX
			if (with_header) { print_header(aA, "mkdir", aA["stats/mkdir"], aA["test/DEST_DIR"], aA["test/HOME_DIR"]) }
			if (reverse) {
				for(i = aA["linenum/end"]; i >= aA["linenum/start"]; i--) { print_mkdir(R[i]) }
			} else {
				for(i = aA["linenum/start"]; i <= aA["linenum/end"]; i++) { print_mkdir(R[i]) }
			}

		} else if ("2" == X[p]) { # 2(file back-up)
			newline = 1
			if (with_header) { print_header(aA, "backup", aA["stats/bkp-f"], aA["test/DEST_DIR"], aA["test/HOME_DIR"]) }
			if (reverse) {
				for(i = aA["linenum/end"]; i >= aA["linenum/start"]; i--) { print_bkp_f(R[i]) }
			} else {
				for(i = aA["linenum/start"]; i <= aA["linenum/end"]; i++) { print_bkp_f(R[i]) }
			}

		} else if ("3" == X[p]) { # 3(file copy)
			newline = 1
			if (with_header) { print_header(aA, "copy", aA["stats/cp-f"], aA["test/DEST_DIR"], aA["test/HOME_DIR"]) }
			if (reverse) {
				for(i = aA["linenum/end"]; i >= aA["linenum/start"]; i--) { print_cp_f(R[i]) }
			} else {
				for(i = aA["linenum/start"]; i <= aA["linenum/end"]; i++) { print_cp_f(R[i]) }
			}

		} else if ("4" == X[p]) { # 4(basic datetime)
			print aA["start/DATETIME"]

		} else if ("5" == X[p]) { # 5(basic status)
			print aA["status"]
		}
	}
	if (FEATURE && newline) {
		print ""
	}
}

function print_header(aA, a1, a2, a3, a4, a5) { # {{{1
#printf "(aA) a1(%s) a2(%s) a3(%s) a4(%s) a5(%s)\n", a1,a2,a3,a4,a5 # XXX
	printf "<>\t%s\t%s%s%s%s%s\n", aA["start/DATETIME"], a1, ""!=a2?("\t"a2):"", ""!=a3?("\t"a3):"", ""!=a4?("\t"a4):"", ""!=a5?("\t"a5):""
}

function print_cp_f(log_entry,   X) { # {{{1
	split(log_entry, X)
	# [action] ::= ""|"copy"|"overwrite"             src   dst [action] [backup]
	if (X[2] == "cp-f") { printf "%s\t%s\t%s\t%s\n", X[3], X[4], X[5], X[6] }
}

function print_bkp_f(log_entry,   X) { # {{{1
	split(log_entry, X)
	#                                         src   dst
	if (X[2] == "bkp-f") { printf "%s\t%s\n", X[3], X[4] }
}

function print_mkdir(log_entry,   X) { # {{{1
	split(log_entry, X)
	#                                         tgt   existing
	if (X[2] == "mkdir") { printf "%s\t%s\n", X[3], X[4]
	}
}

function pretty_status(s) { # {{{1
	return substr(s, index(s, ")") +1)
}

