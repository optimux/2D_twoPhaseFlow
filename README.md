# 2D_twoPhaseFlow
This repository contains all the codes and documentation necessary for simulate a two-phase flow in two dimensions.
 
# Making videos with ffmpeg
ffmpeg -framerate 1/0.2 -i img%d.jpg -c:v libx264 -r 5 -pix_fmt yuv420p out.mp4

* If we have some scaling problems, then:

ffmpeg -framerate 1/0.2 -i img%d.jpg -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -pix_fmt yuv420p sn.mp4




