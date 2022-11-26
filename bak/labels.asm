//--------------------------------
//Slug vs Lettuce
//by Richard Bayliss
//(C)2022 Scene World - Issue 32
//--------------------------------

// Labels and pointers

//Hardware screen pointer shortcuts

.label screenRam = $0400        // Default screen RAM memory
.label colourRam = $d800        // VIC2 screen Colour RAM memory

// Music label shortcuts

.label titleMusic = $00     // Title music is track #0
.label gameMusic = $01      // In game music is track #1
.label wellDoneJingle = $02 // Well done jingle is track #4
.label getReadyJingle = $04 // Get ready jingle is track #2
.label gameOverJingle = $03 // Game over jingle is track #3


.label musicInit = music        // Music initialise address ($6000)
.label musicPlay = music+3      // Music play address       ($6003)
.label sfxInit = music+6    // Goat tracker SFX implemented in project ($6006)

//Collision char (Referred to charpad, the char value that represents)
//the platform in which the Slug should land on

.label  platformChar = 65

//Defining sprite labels to objPos table. So we know which object is 
//operating according to the code.

.label slugPosX = objPos        // sprite 0 = Slug
.label slugPosY = objPos+1
.label lettucePosX = objPos+2 // sprite 1 = Lettuce
.label lettucePosY = objPos+3
.label dropletPosX = objPos+4  //objPos+4 to 15 are sprites 2-7
.label dropletPosY = objPos+5  //which are salty water droplets

.label slugPosXHW = $d000       // Hardware sprite positions for sprite 0 (The slug)
.label slugPosYHW = $d001
.label slugPosXMSBHW = $d010 

.label platformCharValue = 65 //Charset ID to prevent the slug from jumping

.label waterFallChar1 = 70  // Charset ID for background animations
.label waterFallChar2 = 71
.label waterFallChar3 = 72

.label collisionWidth = $10 // Size of sprite to char collision width
.label collisionHeight = $1e // Size of sprite to char collision height 
.label collZP = $02
.label bottomGroundPosition = $c4 // The most bottom ground position in which the player can fall to

// Box collider boundary sizes for sprites

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

// Time of shield before lives are lost

.label shieldDuration = 255