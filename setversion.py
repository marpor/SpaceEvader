#! /usr/bin/python

import re

name = "SpaceEvader"
filename = "spaceevader-"
major = 0
minor = 20
micro = 0
copyright = "2021 marpor"

longverstr = "%d.%d.%d" % (major, minor, micro)
verstr = "%d.%d" % (major, minor)

# Generate Version.gd 
open("scripts/Version.gd","w").write(f"""\
extends Node

var minor = {minor}
var major = {major}
""")

# Update names and versions in export_presets.cfg
examplestrings = """\
export_presets.cfg

application/file_version="0.17.0"
application/product_version="0.17.0"

application/short_version="0.17"
application/version="0.17"
application/short_version="0.17"
application/version="0.17"

export_path="export/html/index.html"
export_path="export/spaceevader-0.17.apk"
export_path="export/spaceevader-0.17.exe"
export_path="export/SpaceEvader-0.17.ipa"
export_path="export/SpaceEvader-0.17.dmg.zip"
"""

fn = "export_presets.cfg"
lines = open(fn).readlines()
of = open(fn, "w")
for l in lines:

	# long version strings
	l = re.sub(\
		r'(.+version=")\d+\.\d+\.\d+(")', \
		r'\g<1>' + longverstr + r'\2', \
		l)

	# short version strings
	l = re.sub(\
		r'(.+version=")\d+\.\d+(")', \
		r'\g<1>' + verstr + r'\2', \
		l)


	# path strings
	l = re.sub(\
		r'(.+path=".*\-)\d+\.\d+(.*")', \
		r'\g<1>' + verstr + r'\2', \
		l)

	of.write(l)
