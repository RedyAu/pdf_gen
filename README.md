# PDF-GEN
Convert your online slideshow classes to PDFs, to make learning easier.
Never need to skip around class videos for a piece of information again!

**Easier to use releases will be available "soon", to use the project right now, you need a Dart programming environment and ffmpeg installed.**

### Usage
On first run, the program will create the following folders:
 - `PDF-GEN/Souce Videos`
 - `PDF-GEN/TEMP`
 
Place your original videos into the `Souce Videos` folder. They can be organized however you like, the script will follow any folder structure recursively.\
PDF files will be created in the same place and with the same name as original videos.\
*WIP: Edit the config file to suit your needs. (There is no config file yet, the configurable variables are at the beginning of the code.*\
If you have all the videos you want to convert, run the program again.

### How it works
The program does the following for every video it finds in the `Source Videos` folder:
 1. Extract frames from the original video. You can choose not to extract every single frame, just one every second for example. The script uses `.bmp` files to make the next steps faster and more accurate.
 2. Mark unique frames. You can set the transition length at the front of the videos (maybe you have a little intro or a fade-in), and the transition length between slides. Tune these with care for the best results. You should also change the compare fidelity value if you're getting duplicate or missing slides.
 3. Assemble markes frames into a PDF file and export it next to the video.
 
After this, you can run an OCR on the PDF files manually to make them searchable, if you want to.\
I recommend downloading [PDF24](https://www.pdf24.org/), as it's offline (runs on your own computer), free, and works great in many languages; also you can add many files to OCR at once and leave it running, just as you can with this very script.
