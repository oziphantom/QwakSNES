# QWAK SNES PORT

This is a "to learn from" example game project. It is simple and small, 1 32K bank for all the code, and its not even 16K of code. This was originally made for the RGCD 16K Compo for the Commodore 64. It was then ported to the Commander X16 and then now ported to the SNES. The orginal game by Jamie Woodhouse was for the BBC Micro, he also made an enhanced Amiga OCS port, then later a very different GBA version. Which then was ported to iOS but has been removed by Apple. However the HD version is also available on Windows and Mac and can be found here https://www.mrqwak.com/games/qwak/

This C64 port is a blend from the BBC Micro version to the Amiga version. 16K limited me quite a lot. This is also the 1.3 version of the game however the Password entry system has been commented out. An exercise to the reader is to put it back.

I never knew the original, so it was Saul C's idea. Also 1 week before the deadline he pointed out to me that everything should be moving twice as fast.. he could have told me 2 months before when I showed him the enemy first moving, but no. So things got doubled, collision got pushed to and beyond limits.

The collision is a little hokey, you can embed into corners, but it has saved me soooooo many times in the game, I called it "a feature". You are welcom to fix it though ;)

It is a single screen action puzzle game, with 32 levels, it is "old skool hard", has a score system, HUD and a large variety of entites and bosses.

There is the 8bit version which is mostly 8bit code only, a couple of SNES custom points are in 16bit mode as well. This is if you have trouble following switching from 8 to 16 and vise versa confusing this version may be easier to follow. 
The 16bit version, I have upgraded the code to 16bit mode where applicable.

It is worth noting that this is not the most perfect complex ideal code, some things in here a hokey, or done in a long winded way as simple repeated code compresses better. The C64 version was right up against the 16K limit ( as it also had to include the sound and graphics ) and truth be told this 1.3 version actually went over the 16K but it was post compo.

The game is designed for a PAL console, it works perfectly fine on an NTSC console just it will be faster as all the delays and movement rates are designed for 50hz.

Documents on how the engine logically works are coming after the 16bit version is complete.

# Requirements
assembly - 64tass ( https://sourceforge.net/projects/tass64/ ) a pure ANSI C compiler that works on almost everything, Amiga 500 almost everything.
I also highly recommend you read the extensive manual as well while looking at this code http://tass64.sourceforge.net/

If you wish to improve the graphics ( a great starting task, as tghe graphics are currently C64 spec) you will need Optiroc's SuperFamiconv ( https://github.com/Optiroc/SuperFamiconv ) pre converted binaries are provided for those that wish to simple build and run.

# To build
on windows just run `build_run.bat` if you are on something else the magic line is `64tass.exe -a QWAKSNES.asm -b -X -o qwakSNES.sfc --no-caret-diag --dump-labels -l "qwakSNES.tass" -L "qwakSNES.list" --verbose-list --line-numbers` if you don't care about the listing you can just do `64tass.exe -a QWAKSNES.sfc -b -X -o qwakSNES.sfc`

# Code editing and reading notes
I use http://www.popelganda.de/relaunch64.html and set it to 64tass mode.
To build on its F5 the custom comamnds you need is `SOURCEDIR/build_run.bat` which goes in the settings gear cog > Compile and Run scripts.

The text is written with a **tab space of 3** which limits indentation going to far and 3 is the size of a opcode so it lines up nicely. 

If you don't use Reluanch64, I also use 'Visual Studio Code' with Josh Neta's 65816 Assembly plug in, I don't have F5 to build set up though, so don't ask me how.

The file is in **Windows 1252** encoding and you will need to open and edit in this format. If you don't and use UTF-8 you will get an error about a unknown character, that character as documented in the file is `£` simple paste it in and save and you should be fine to continue in UTF-8.

# Converting graphics
There are bat files with the right commands, they are trivial to understand, they just call the converter with params so if you are not on Windows you should have no issues converting them to whatever your machine uses. 

# Other useful things
Having FullSNES on hand will be a great help http://problemkaputt.de/fullsnes.htm

Also having an instruction reference is nice https://undisbeliever.net/snesdev/65816-opcodes.html#inc-increment is compact but sometimes lack the extra detail needed for some cases to which I lean upon http://www.6502.org/tutorials/65c816opcodes.html

For intro to the SNES and how my cart and GameLoop/NMI is set up and works line by line see my video series here https://www.youtube.com/playlist?list=PLgWFqnBTsWTP0G4X-9OwKjFlOqLCgq5rs video 4 is of particular not for this topic

Also if you are lost on the 64tass fancy data reformating 3 mins of the first video in this playlist should clear it up nicely https://www.youtube.com/watch?v=4gwOWiWhKC8&list=PLgWFqnBTsWTPecxvr_9V57eAnVM1XbuQO but the others "won't hurt" either.
