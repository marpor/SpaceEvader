import os, glob
from xml.dom import minidom


def doFile(fname):
  name = os.path.splitext(os.path.basename(fname))[0]

  doc = minidom.parse(fname)  # parseString also exists

  path_strings = [path.getAttribute('d') for path in doc.getElementsByTagName('path')]
  viewBox = doc.getElementsByTagName('svg')[0].getAttribute("viewBox")
  doc.unlink()
  
  coords = [int(c) for c in viewBox.split(" ")]

  x0,y0,x1,y1 = coords
  w = x1-x0
  h = y1-y0
  
  polstr = ", ".join([str(c) for c in [x0,y0, x1,y0, x1,y1, x0,y1]])
  posstr = "%d, %d" %(-w/2, -h/2)
  print(name, polstr)

  of = open(name + ".tscn", "w")
  of.write("""\
[gd_scene load_steps=3 format=2]

[ext_resource path="res://parts/svgs/{name}.svg" type="Texture" id=1]
[ext_resource path="res://parts/Part.gd" type="Script" id=2]

[node name="{name}" type="Area2D"]
script = ExtResource( 2 )

[node name="sprite" type="Sprite" parent="."]
texture = ExtResource( 1 )

[node name="colpol" type="CollisionPolygon2D" parent="."]
visible = false
position = Vector2( {posstr} )
polygon = PoolVector2Array( {polstr} )
""".format(**locals()))

if 0:
  doFile("svgs/Feat32.svg")
else:
  for fname in glob.glob("svgs/*.svg"):
    doFile(fname)

