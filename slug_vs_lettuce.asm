//--------------------------------
//Slug vs Lettuce
//by Richard Bayliss
//(C)2022 Scene World - Issue 32
//--------------------------------

// Labels and pointers
//Hardware pointer shortcuts

.label screenRam = $0400	// Default screen RAM memory
.label colourRam = $d800	// VIC2 screen Colour RAM memory

.label musicInit = music	// Music initialise address
.label musicPlay = music+3	// Music play address
.label sfxInit = music+6    // Goat tracker SFX implemented in project

//Collision char (Referred to charpad, the char value that represents)
//the platform in which the Slug should land on

.label  platformChar = 65

//Defining sprite labels to objPos table. So we know which object is 
//operating according to the code.

.label slugPosX = objPos	// sprite 0 = Slug
.label slugPosY = objPos+1
.label lettucePosX = objPos+2 // sprite 1 = Lettuce
.label lettucePosY = objPos+3
.label dropletPosX = objPos+4  //objPos+4 to 15 are sprites 2-7
.label dropletPosY = objPos+5  //which are salty water droplets

.label slugPosXHW = $d000
.label slugPosYHW = $d001
.label slugPosXMSBHW = $d010 

.label platformCharValue = 65 //Charset ID to prevent the slug from jumping
.label waterFallChar1 = 70
.label waterFallChar2 = 71
.label waterFallChar3 = 72

.label collisionWidth = $10 // Size of sprite to char collision width
.label collisionHeight = $1e // Size of sprite to char collision height 
.label collZP = $02
.label bottomGroundPosition = $c4 // The most bottom ground position in which the player can fall to

// Box collider sizes for sprites
.label spriteBoxLeft = 6
.label spriteBoxRight = 12
.label spriteBoxTop = 12
.label spriteBoxBottom = 32

.label testPosX = $56
.label testPosY = $40

// Screen positions for text object

.label scoreTextPos = $07c6
.label livesTextPos = $07d4
.label timeTextPos = $07d9 
.label timeTextPos2 = $07db
.label timeTextPos3 = $07dc
.label hiScoreTextPos = $07e2

BasicUpstart2(mainCode)

		//Game soundtrack
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
mainCode:	
		.import source "gamecode.asm"
		