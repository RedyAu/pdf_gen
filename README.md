# PDF-GEN
Convert video slideshows classes to PDFs!
Never need to skip around online class videos for a piece of information again!

### How to use (Windows)
(If you're on Linux, you can figure it out)

[Download the latest release.](https://github.com/RedyAu/pdf_gen/releases)

To use the program, you must have **ffmpeg** installed. [How to download ffmpeg?](https://www.wikihow.com/Install-FFmpeg-on-Windows)

On the first run, the program will create the following folders:
 - `PDF-GEN/_Source Videos`
 - `PDF-GEN/TEMP`
 - `PDF-GEN/config.txt`
Edit the config file to suit your needs.

Place your video files (.mp4, .avi, .mov) into the `_Source Videos` folder. They can be organized however you like, the program will follow any folder structure recursively.\
PDF files will be created in the same place and with the same name as original videos.\
If you placed in all the videos you want to convert, run the program again.
**Important: For longer video files, you might have to have more than 2GB of free storage space on your drive!** All temporary files are deleted when the program completes.

### How it works
The program does the following for every video it finds in the `_Source Videos` folder:
 1. Extract frames from the original video. You can choose not to extract every single frame, just one every second for example. By default the program uses `.bmp` files to make the next steps faster and more accurate.
 2. Mark unique frames. You can set the transition length at the front of the videos (maybe you have a little intro or a fade-in), and the transition length between slides. Tune these with care for the best results. You should also change the compare fidelity value if you're getting duplicate or missing slides.
 3. Assemble marked frames into a PDF file and export it next to the video.
 
After this, you can run an OCR on the PDF files manually to make them searchable, if you want to.\
I recommend downloading [PDF24](https://www.pdf24.org/), as it's offline (runs on your own computer), free, and works great in many languages; also you can add many files to OCR at once and leave it running, just as you can with this very script.
