REM export the tiles out
.\superfamiconv.exe -i .\Sprites_SNES.png -t sprites_SNES.bin -S -R -D -F -v
REM I want 3 palletes output not just the 1 used in the image so do it separately
.\superfamiconv.exe palette -S -v -R -P3 -i .\Sprites_SNES.png -d sprites_SNES.pal  
