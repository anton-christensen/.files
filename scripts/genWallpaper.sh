#!/bin/sh
cd /home/anton/.files/apps/bubbles/ ; ./bubbles ; ppmtojpeg /home/anton/.files/apps/bubbles/img.ppm > /home/anton/Pictures/bubble.jpg ; feh --bg-scale "/home/anton/Pictures/bubble.jpg"
