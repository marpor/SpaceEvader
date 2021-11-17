import os, glob

import fontforge
#fontforge.loadNameList('aglfn.txt') # Might be optional

#font = fontforge.open('existing.sfd')
font = fontforge.font() # new font

font.fontname = "Space Evader Regular"
font.familyname = "Space Evader"
font.fullname = font.fontname

font.encoding = "UnicodeFull"

font.ascent = 96
font.descent = 16
font.em = 112

path = "" #"C:/Users/m/OneDrive/godot/SpaceEvader/fonts/"

glyphNameAndOutlineFilename = {
}

for filename in glob.glob(path + "chars/*.svg"):
  path, name = os.path.split(filename)
  name, ext = os.path.splitext(name)
  if "-" in name:
    prefix, name = name.split("-")
    if prefix == "lower":
      name = name.lower()
  glyphNameAndOutlineFilename[name] = filename

for name, filename in glyphNameAndOutlineFilename.items():
  print(name, filename)
  glyph = font.createMappedChar(name)
#  glyph.width = 0
  glyph.importOutlines(filename)
  bbox = glyph.boundingBox()
  glyph.width = int(bbox[2]-bbox[0]) + 4
  height = int(bbox[3]-bbox[1])
  print(glyph.width, bbox)
#  glyph.width = 48*8
  # May need to set glyph.width here

font.selection.all()
font.removeOverlap()
font.simplify()
font.correctDirection()

font.generate('font.ttf')
font.save('font.sfd')
