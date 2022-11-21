#!/usr/bin/python

import argparse
import numpy as np
from PIL import Image

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('image')
parser.add_argument('signal')
parser.add_argument('step', type=int)
parser.add_argument('plots', type=int)
parser.add_argument('qfactor', type=int)
parser.add_argument('lowpass', type=int)
parser.add_argument('trigger', type=float)
parser.add_argument('symbol')
parser.add_argument('name')
parser.add_argument('cat')
parser.add_argument('csv')

args = parser.parse_args()
step = args.step
plots = args.plots
trigger = args.trigger
csv = args.csv
cat = args.cat
symbol = args.symbol
name = args.name

def getimage(filename):
   return Image.open(filename).convert('L')

def loadpicture(image):
   return np.asarray(image)

def loadcoords(image, threshold_level = 50):
   pixels = np.asarray(image)
   return sorted(np.column_stack(np.where(pixels < threshold_level)), key=lambda k: [k[1], k[0]])

image = getimage(args.image)
picture = loadpicture(image)
coords = loadcoords(image)
signal = loadcoords(loadpicture(getimage(args.signal)))
rawdata = [0.0]
divisions = 16
w, h = image.size
qfactor = int(args.qfactor * w / 1000)
lowpass = int(args.lowpass * w / 1000)

newy = 0
oldx = coords[0][1]

for plot in range(0, plots):
   for x in range(0, w):
      column = picture[:, x]
      x = x+1
      values = sorted(np.column_stack(np.where(column < 50)))
      dist = 0
      stepping = 0
      for y in range(1, len(values)):
         dist = values[y]-values[y-1]
         if dist > step * 3:
            stepping = stepping+1
         if stepping == plot:
            yval = h-values[y]
            rawdata.append(yval[0])
            break

lopass = [0]
hipass = [0]
filtered = [0]

w = len(rawdata)

smooth = 15
for x in range(0, w-smooth):
   value = 0
   for y in range(x, x+smooth):
      value = value + rawdata[y]
   rawdata[x] = value / smooth

for x in range(1, smooth):
   del rawdata[w-x]

w = len(rawdata)

for x in range(qfactor, w-qfactor):
   value = 0
   for y in range(x-qfactor, x+qfactor):
      value = value + rawdata[y]
   value = value / (qfactor * 2 + 1)
   lopass.append(value)
   if rawdata[x] - value < 0:
      hipass.append(0)
   else:
      hipass.append(rawdata[x] - value)

w = len(lopass)

for x in range(lowpass, w-lowpass):
   value = 0
   for y in range(x-lowpass, x+lowpass):
      value = value + hipass[y]
   value = value / (lowpass * 2 + 1)
   filtered.append(value)

csv_file = open(csv+"_raw.csv", "a+")
streamdata = rawdata
w = len(streamdata)
for x in range(0, w):
   norm = 1.0/(np.max(streamdata)-np.min(streamdata))
   value = streamdata[x]*norm
   csv_file.write(str(value)+"\n")
csv_file.close()

csv_file = open(csv+"_lopass.csv", "a+")
streamdata = lopass
w = len(streamdata)
for x in range(0, w):
   norm = 1.0/(np.max(streamdata)-np.min(streamdata))
   value = streamdata[x]*norm
   csv_file.write(str(value)+"\n")
csv_file.close()

csv_file = open(csv+"_hipass.csv", "a+")
streamdata = filtered
w = len(streamdata)
for x in range(0, w):
   norm = 1.0/(np.max(streamdata)-np.min(streamdata))
   value = streamdata[x]*norm
   csv_file.write(str(value)+"\n")
csv_file.close()

csv_file = open(csv+"_hipass.csv", "r")
lines = csv_file.readlines()
w = len(lines)-1
streamdata = [0.0];
for x in range(0, w):
   streamdata.append(float(lines[x]))
csv_file.close()

w = len(streamdata)

cat_file = open(cat, "w")

lock = False
delta_x = 0
for x in range(0, w):
   norm = 1.0/(np.max(streamdata)-np.min(streamdata))
   value = streamdata[x]*norm
   if value > trigger and not lock:
      lock = True
      delta_x = x
   elif value < trigger and lock:
      cat_file.write(str(streamdata[int(delta_x+(x-delta_x)/2)]*norm)+"  "+str(1000000000000.0/x)+" "+symbol+" "+name+"\n")
      lock = False
cat_file.close()
