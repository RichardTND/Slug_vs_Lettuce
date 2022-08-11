//--------------------------------
//Slug vs Lettuce
//by Richard Bayliss
//(C)2022 Scene World - Issue 32
//--------------------------------

// Import labels and pointers 

.import source "labels.asm"

// Setup the BASIC run SYS jump address.
BasicUpstart2(mainCode)

		// Import the Goat Tracker game soundtracks
		// (The music has two main tunes and two jingles)
		
		*=$1000 "MUSIC"
music:		
		.import c64 "c64/music.prg"
		
		//Game sprites 
		*=$2000 "SPRITES"
		.import c64 "c64/sprites.prg"
		
		//Game graphics character set
		*=$3000 "GAME CHARSET"
charMem:
		.import binary "c64/gamecharset.bin"
		
		//Actual game screen 
		*=$3800 "GAME SCREEN"
gameScreen:		
		.import binary "c64/gamescreen.bin"
		
		//Game screen charset colour data
		*=$3c00 "GAME ATTRIBS"
gameAttribs:		
		.import binary "c64/gameattribs.bin"
		
		//Main game code
		*=$4000 "GAME CODE"
gameCode:		
		.import source "gamecode.asm"
		
		//Title screen code 
		*=$5000 "TITLE SCREEN CODE"
mainCode:	
		.import source "titlescreen.asm"

		*=$7000 "TITLE SCREEN LOGO"
logoMatrix:
		.import binary "c64/logo.bin"

		