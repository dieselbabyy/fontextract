# fontextract by dieselbaby

This is the first release (a working one, though I will eventually add more features to this) of a helpful little shell script that I created for those of us who might be using a lot of different font files, such as those downloaded from sites like [dafont](https://dafont.com) 

## Requirements/dependencies

- bash (duh)
- `unzip` command
- [`fc-query`](https://linux.die.net/man/1/fc-query) command (for font file renaming)

## How to use?

Download `fontextract.sh` from this repo or copy/paste it into a new file on your machine, make any changes you want to make (if you want to make any), and save it.  

**Note**: *You'll want to make sure that you save this to the directory where your font directories are located/where the zip archives are located, if you don't want to use the options mentioned in the next section to specify your input/output directories.*

Then run `chmod +x fontextract.sh` to make it executable.

All you've gotta do then, is run it as a normal script -- from within the directory you saved it to, just type `./fontextract.sh` and hit enter.

## Optional arguments


