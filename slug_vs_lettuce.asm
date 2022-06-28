//Slug vs Lettuce
//by Richard 
//(C)2022

// Labels/ZP pointers

//Hardware pointer shortcuts

.label screenRam = $0400
.label colourRam = $d800
.label musicInit = $1000
.label musicPlay = $1003

//Collision char 

.label platformChar = $65

//Defining sprite labels to objPos 
//table. So we know which object is 
//operating according to the code.

.label slugPosX = objPos	// sprite 0
.label slugPosY = objPos+1
.label lettucePosX = objPos+2 // sprite 1
.label lettucePosY = objPos+3
.label dropletPosX = objPos+4  //objPos+6 to 15 are sprites 2-7
.label dropletPosY = objPos+5


		//Game soundtrack
		*=$1000 "MUSIC"
		.import c64 "c64/music.prg"
		
		//Game sprites 
		*=$2000 "SPRITES"
		.import c64 "c64/sprites.prg"
		
		//Game graphics character set
		*=$3000 "GAME CHARSET"
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
		.import source "gamecode.asm"
		