String defaultConfig = """Config file for PDF-GEN
Written by RedyAu in 2021
ONLY EDIT THE VALUES AFTER THE COLONS! IF YOU MESSED UP THE FILE, JUST DELETE IT.

--- EXTRACTING FRAMES ---
- Extract every Nth frame: 20
1 means extract every single frame.

- Extracted frames extension: .bmp
Recommended: .bmp
.jpg file size is smaller, but introduces noise and makes the next step slower and less accurate.
Warning: Using .bmp, for a longer video, you may need multiple GBs of hard disk space!


--- MARKING USEFUL SLIDES ---
- Percentage treshold for new slide: 0.1
Ranges 0-100. Can be any fraction. If no pixels are the same, will be 100.
Recommended values:
0.1 for .bmp extraction setting (may be decreased further if there are smaller animations on screen)
0.6-1.0 for .jpg extraction setting (may have duplicates and/or skip slides!)

- Intro transition lenth in frames: 0
Counts actually extracted frames, take your setting value at "extract every Nth frame" into account!

- Transition length between slides in frames: 1
As the script goes trough the extracted frames, if it finds a difference beyond the treshold, it will jump ahead by this amount, mark that frame as a useful slide, and continue checking from there.
Counts actually extracted frames, take your setting value at "extract every Nth frame" into account!


--- EXPORTING TO PDF ---
- JPG quality of slides: 60
.bmp frames get converted to .jpg before getting added to the exported .pdf files. Set the quality in percentages here. 100 is lossless (but bigger).""";
