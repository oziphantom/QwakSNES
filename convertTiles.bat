REM export the dynamic tiles out
.\superfamiconv.exe -i .\back_shadow.png -t back_shadow.bin -p chars.pal -R -D -F -v
REM export the fixed tiles out
.\superfamiconv.exe -i .\fixed_section_chars.png -t fixed_section_chars.bin -R -D -F -v
REM export the hud tiles out
.\superfamiconv.exe -i .\top_fixed_chars.png -t top_fixed_chars.bin -R -D -F -v
REM export the font out
.\superfamiconv.exe -i .\font4bpp.png -t font4bpp.png.bin -R -D -F -v

