//Slug vs Lettuce game code

//	Switch off previous IRQ raster 
//  interrupts, and prepare the game 
//  screen 

//---------------------------------------------------------- 

gamecode:	

			sei
			 
			/* Clear out all of the interrupts and SID and 
		     do a short delay cycle routine */

			ldx #$31
			ldy #$ea
			lda #$81
			stx $0314
			sty $0315
			sta $dc0d
			sta $dd0d
			lda #$00
			sta $d01a
			sta $d019

			// Switch off the screen for a little bit

			lda #$0b
			sta $d011

			lda #$00
			sta $d020
			sta $d021

			// Clear out the SID chip

			ldx #$00
noTitleSid:	lda #$00
			sta $d400,x
			inx 
			cpx #$18
			bne noTitleSid 
			
			ldx #$00
stopsnd:	lda #$00
			sta $d400,x
			inx 
			cpx #$18 //(SID: $D400-$D418)
			bne stopsnd 
			
//---------------------------------------------------------- 

/* Draw out the main game screen. This game screen
   was created using Charpad V2.0 (Work file has 
   also been included. Also draw the colour from 
   the attributes table into the screen's colour RAM */


			ldx #$00
drawScreen: lda gameScreen,x
			sta screenRam,x
			lda gameScreen+$100,x
			sta screenRam+$100,x
			lda gameScreen+$200,x
			sta screenRam+$200,x
			lda gameScreen+$2e8,x
			sta screenRam+$2e8,x
			 			
			ldy gameScreen,x
			lda gameAttribs,y
			sta colourRam,x
			ldy gameScreen+$100,x
			lda gameAttribs,y
			sta colourRam+$100,x
			ldy gameScreen+$200,x
			lda gameAttribs,y
			sta colourRam+$200,x
			ldy gameScreen+$2e8,x
			lda gameAttribs,y
			sta colourRam+$2e8,x 
			inx 
			bne drawScreen 

//---------------------------------------------------------- 

			// Zero score as digits

			ldx #$00
zeroScore:
			lda #$30
			sta score,x 		
			inx 
			cpx #6
			bne zeroScore

			// Set the starting number of lives to 5 ($35 = number character 5)
			lda #$39
			sta lives

			// Set the starting time to 9 minutes and 59 seconds. 10 mins = 9:59 - 0:00

			lda #$39
			sta time
			lda #$35
			sta time+1
			lda #$39
			sta time+2

			// Then refresh the score panel

			jsr updatePanel
			
			/* Setup VIC2 graphics  charset and background 
   			colours. */
			
			lda #$18 //Screen multicol
			sta $d016 // on
			lda #$1c //Charset at $3000
			sta $d018
			
			//Background colour scheme
			
			lda #$00
			sta $d020 //Border +
			sta $d021 //background col
			lda #$09	
			sta $d022 //BG Mcol 1
			lda #$08
			sta $d023 //BG Mcol 2
			
			// Initialise all game pointers
			
			ldx #$00
initpointers: lda #$00
			sta pointers,x
			inx 
			cpx #pointersend-pointers 
			bne initpointers 
			

			// Ensure slug falls at start of game

			lda #1
			sta playerIsFalling
			
			// Setup sprite hardware properties

			lda #$0b
			sta $d025
			lda #$01
			sta $d026
			lda #$ff
			sta $d015
			sta $d01c
			lda #0
			sta $d017
			sta $d01b
			sta $d01d
					
			ldx #$fb
			txs
//---------------------------------------------------------- 

// Little delay while screen blank (prevent fire button sensitivity)

			ldx #$00
gdelay1:	ldy #$00
gdelay2:	iny 
			bne gdelay2
			inx 
			bne gdelay1

//----------------------------------------------------------
// Setup game IRQ raster interrupts 

			ldx #<gameIRQ 
			ldy #>gameIRQ
			lda #$7f
			stx $0314
			sty $0315
			sta $dc0d 
			sta $dd0d 
			lda #$32
			sta $d012 
			lda #$1b
			sta $d011
			lda #$01
			sta $d01a 
			lda #$00
			jsr musicInit
			cli

//---------------------------------------------------------- 

// Setup the Get Ready screen (and sprites)
			
getReadyScreen:			

			ldx #$00
putGetReadyPos:
			lda getReadyPos,x
			sta objPos,x 
			inx
			cpx #16 
			bne putGetReadyPos 

			// Fill sprites green 

			ldx #$00
makeGreen1:
			lda #$0d
			sta $d027,x 
			inx 
			cpx #8
			bne makeGreen1 

			// Make sprite GET READY frame

			lda letter_g
			sta $07f8 
			lda letter_e 
			sta $07f9 
			lda letter_t 
			sta $07fa 

			lda letter_r 
			sta $07fb 
			lda letter_e
			sta $07fc 
			lda letter_a 
			sta $07fd 
			lda letter_d
			sta $07fe
			lda letter_y
			sta $07ff 

			lda #0
			sta fireButton

//---------------------------------------------------------- 

/* Main get Ready Loop, which calls a subroutine to  
   synchronize the raster with IRQ interrupt so that the 
   speed of the animation/game play matches the value inside 
   the IRQ raster interrupt */

getReadyLoop:
			lda #0
			sta rp
			cmp rp
			beq *-3
			jsr expandMSB
			lda $dc00
			lsr 
			lsr 
			lsr 
			lsr
			lsr
			bit fireButton
			ror fireButton
			bmi getReadyLoop
			bvc getReadyLoop

//---------------------------------------------------------- 

// Setup and reposition main game sprites 			

			lda #$0d
			sta $d028
			lda #0
			sta shieldPointer
			lda #shieldDuration
			sta slugShieldTime
			
			// Reset all sprites
			
			ldx #$00
zerosprts:	lda #$00
			sta $d000,x	  
			sta objPos,x
			inx 
			cpx #16
			bne zerosprts
			
			// Set starting position 
			
			ldx #$00
setstart:	lda startPos,x
			sta objPos,x
			inx
			cpx #16 
			bne setstart
			
			ldx #$00
setdfltsprs:
			lda defaultFrames,x
			sta $07f8,x
			lda defaultColour,x
			sta $d027,x
			inx
			cpx #8
			bne setdfltsprs

			jsr randomLettucePos

			lda #0
			sta fireButton

			jmp gameLoop

//---------------------------------------------------------- 

/* The main IRQ raster interrupt. We  only need to use one
   interrupt for this game. */

gameIRQ:	asl $d019 
			lda $dc0d 
			sta $dd0d
			lda #$fa // Pos. of bottom
			sta $d012 //raster
			jsr musicPlay
			lda #1
			sta rp //Raster pointer
			jmp $ea7e
	
//---------------------------------------------------------- 

// The main game loop subroutine

gameLoop:	jsr syncRaster	

			// Game control
			jsr playerProperties
			jsr waterDroplets
			jsr spriteToSpriteCollision
			jsr playTime
			jmp gameLoop

//---------------------------------------------------------- 

/* Synchronize timer with raster position (rp), ensure 
   sprites use whole screen area X, also animate the 
   water fall and all game sprites. */

syncRaster:	lda #0
			sta rp
			cmp rp
			beq *-3
			jsr expandMSB
			jsr animateWater
			jsr animateSpriteData
			rts
//---------------------------------------------------------- 	

// Make object position pointers into actual hardware sprite
// positions.
			
expandMSB:	ldx #$00
update2spr: lda objPos+1,x
			sta $d001,x
			lda objPos,x
			asl
			ror $d010
			sta $d000,x
			inx
			inx 
			cpx #16
			bne update2spr
			rts

//---------------------------------------------------------- 


// Animate the waterfall by scrolling  the waterfall chars downwards 

animateWater:
			lda gfxAnimDelay
			cmp #4
			beq gfxAnimMain
			inc gfxAnimDelay
			rts 

//---------------------------------------------------------- 

// Animate the sprite data - copy sprite frames 
// from table and store to sprite pointers 

animateSpriteData:
				lda spriteAnimDelay
				cmp #6
				beq spriteAnimOk
				inc spriteAnimDelay 
				rts 
				
				// Sprite delay expired call main
				// sprite animation routines

spriteAnimOk:	lda #$00
				sta spriteAnimDelay
				jsr animatePlayer
				jsr animateDroplets
				rts 

				// The main sprite animation for the player
				// and the lettuce it needs to fetch
animatePlayer:
				ldx spriteAnimPointer
				lda slugRightFrame,x
				sta slugRightSprite
				lda slugLeftFrame,x
				sta slugLeftSprite
				lda lettuceFrame,x
				sta lettuceSprite 
				inx 
				cpx #2
				beq loopSpriteAnim1
				inc spriteAnimPointer 
				rts 
loopSpriteAnim1:
				ldx #0
				stx spriteAnimPointer
				rts 

				// The main sprite animation for the 
				// water droplets

animateDroplets:
				ldx spriteAnimPointer2
				lda dropletFrame1,x
				sta $07fa
				lda dropletFrame2,x
				sta $07fb
				lda dropletFrame3,x
				sta $07fc
				lda dropletFrame4,x
				sta $07fd
				lda dropletFrame5,x
				sta $07fe
				lda dropletFrame6,x 
				sta $07ff
				inx 
				cpx #5 
				beq loopSpriteAnim2
				inc spriteAnimPointer2
				rts 
loopSpriteAnim2:
				ldx #$00
				stx spriteAnimPointer2
				rts


//---------------------------------------------------------- 
			
			// The main charset graphics animation 
gfxAnimMain:
			lda #0
			sta gfxAnimDelay
			
			lda charMem+(waterFallChar1*8)+7	
			pha 
			lda charMem+(waterFallChar2*8)+7
			pha 
			ldx #7
movechrsup:	lda charMem+(waterFallChar1*8),x
			sta charMem+(waterFallChar1*8)+1,x
			lda charMem+(waterFallChar2*8),x
			sta charMem+(waterFallChar2*8)+1,x
			dex 
			bpl movechrsup 
			pla 
			sta charMem+(waterFallChar1*8)
			pla 
			sta charMem+(waterFallChar2*8)
			ldx #$00
movechrslft:
			lda charMem+(waterFallChar3*8),x 
			asl 
			rol charMem+(waterFallChar3*8),x
			asl 
			rol charMem+(waterFallChar3*8),x 
			inx 
			cpx #8
			bne movechrslft
			rts

//---------------------------------------------------------- 
			
// Main player properties
playerProperties:
			jsr shieldStatus		// Player's shield on/off
			jsr playerControl		// Player control mechanics
			jsr playerBehaviour		// Player jumping or falling?
			jsr spriteCharCollision // Player to lettuce and/or water droplets collision
			rts
//---------------------------------------------------------- 

// Test player shield 

shieldStatus:

			lda slugShieldTime
			beq noShield
			dec slugShieldTime
			ldx shieldPointer
			lda shieldColourTable,x
			sta $d027 //This is the player sprite colour
			inx 
			cpx #7 
			beq resetFlashShield
			inc shieldPointer
			rts 

resetFlashShield:
			ldx #0
			stx shieldPointer
			lda #5
			rts 
noShield:
			lda #5
			sta $d027 //This is the player sprite colour
			rts			

//---------------------------------------------------------- 

// Main player control 

playerControl:
 
			// Check joystick LEFT 
			
			lda #4
			bit $dc00 
			bne checkRight
			
			// Move slug left until 
			// reached edge of screen
			lda slugLeftSprite 
			sta $07f8          // Hardware sprite ID used for player sprite

			lda slugPosX
			sec
			sbc #1
			cmp #$0c
			bcs updateLeft
			lda #$0c
updateLeft:	sta slugPosX
			 		
			// Check joystick RIGHT
checkRight:			
			lda #8
			bit $dc00 
			bne checkFire
			
			// Move slug right until reached edge of screen

			lda slugRightSprite // Animate the sprite again
			sta $07f8

			lda slugPosX
			clc
			adc #1
			cmp #$a0			
			bcc updateRight
			lda #$a0 
updateRight:
			sta slugPosX
			
checkFire:	lda $dc00 
			lsr
			lsr 
			lsr 
			lsr
			lsr 
			bit fireButton
			ror fireButton
			bmi noJoyControl
			bvc noJoyControl
			lda #0
			sta fireButton
			lda playerIsAllowedToPressFire
			beq noJoyControl 
						 
			ldx #0
			stx playerJumpPointer
			lda #0 
			sta playerIsFalling
			sta playerIsAllowedToPressFire
			lda #1
			sta playerIsJumping
noJoyControl:
			rts 
			
playerBehaviour:
			
			jsr jumpCheck 
			jmp fallCheck 
//---------------------------------------------------------- 

// Check whether or not the player is 
// on ground or jumping. If the 
// pointer playerIsJumping = 0, then
// the player is allowed to jump. Else 
// the routine gets ignored.

jumpCheck:	
			lda playerIsFalling 
			cmp #1
			beq skipJumpFallCheck 
			lda playerIsJumping
			bne makeSlugJump
skipJumpFallCheck:			
			rts 
			
makeSlugJump:
			lda #0
			sta playerIsAllowedToPressFire
			ldx playerJumpPointer
			lda slugPosY 
			clc 
			adc jumpTable,x
			sta slugPosY 
			inx 
			cpx #jumpTableEnd-jumpTable 
			beq endJump
			inc playerJumpPointer 
			
			rts 
			
endJump:	ldx #0
			stx playerJumpPointer
			lda #0
			sta playerIsJumping
			
			lda #1
			sta playerIsFalling
			rts
			
fallCheck:	lda playerIsJumping 
			cmp #1
			beq skipfall
			lda playerIsFalling
			cmp #1 
			beq makeSlugFall
skipfall:			
			rts 
	
makeSlugFall:
			lda slugPosY
			clc 
			adc #4
			sta slugPosY 
			
			rts 
//---------------------------------------------------------- 
						
// Player sprite to char collision			
spriteCharCollision:
			lda playerIsJumping
			cmp #1
			beq skipCollisionLogic
			lda slugPosXHW			// Read sprite0 X pos for slug
			sec 
			sbc #collisionWidth		// Read collision X position
			sta collZP				// Store to the screen column zeropage
			
			lda slugPosXMSBHW		// Read sprite0 X MSB for slug
			sbc #$00
			lsr 
			lda collZP				// perform 16 bit division
			ror
			lsr
			lsr
			sta collZP+3			// Store to selfmod zeropage for X pos 
			
			lda slugPosY			// Read Y position of slug 
			sec 
			sbc #collisionHeight 	// Read collision Y position
			lsr 
			lsr 					//Y-Co-ords 16 bit division	
			lsr 
			sta collZP+4 			// Store to selfmod ROW

			lda #<screenRam			// Read low byte of screen RAM 
			sta collZP+1			// store as screen read low 
			lda #>screenRam 		// Read hi byte of screen RAM 
			sta collZP+2			// store as screen read hi
			
			ldx collZP+4			// Read current row 
			beq checkPlatform		// Then check platform char 
			
nextRow:	lda collZP+1			// Read low byte of screen
			clc 
			adc #40					// 1 full row = 40 chars
			sta collZP+1			// Moved to next row#
			
			lda collZP+2			// Read hi byte of screen 
			adc #$00
			sta collZP+2			// Store to the next column
			dex 
			bne nextRow 
			
			// Row calculation is complete, now check for the platform 
			// character found. If found, stop the slug from falling.
			
checkPlatform:
			
			ldy collZP+3
			lda (collZP+1),y
			cmp #platformCharValue
			beq platformFound 
			
			// Check if the player is already sitting on the platform 
			// or if the player is falling. If either of those have 
			// been active. Prevent the player from falling, 
			// otherwise allow the slug to fall at some speed.
			
			lda #0
			
			sta playerIsJumping
			lda #1
			sta playerIsAllowedToPressFire
			sta playerIsFalling
dontFall:			
			rts

			
			// Platform is found, so collision has now been detected so stop player 
			// from jumping of falling.
			
platformFound:
		 
			lda playerIsJumping
			cmp #1
			beq skipCollisionLogic
			lda #0
			sta playerIsFalling
			sta playerIsJumping 
			
			lda #1
			sta playerIsAllowedToPressFire
skipCollisionLogic:			
			rts
//---------------------------------------------------------- 

// Drop all of the water droplets down the screen.

waterDroplets:
			jsr testOffset
			ldx #$00
dropLoop:	lda dropletPosX,x
			clc 
			adc dropletSpeed,x
			sta dropletPosX,x
			inx 
			cpx #12
			bne dropLoop
			 
			rts

// Test if any droplets have gone out of bounds:
testOffset:
			jsr testDroplet1Out
			jsr testDroplet2Out
			jsr testDroplet3Out
			jsr testDroplet4Out 
			jsr testDroplet5Out
			jmp testDroplet6Out 


testDroplet1Out:
			lda dropletPosY
			cmp #$ca 
			bcc droplet1OK
			jsr randomize
			sta dropletPosX
			lda #0
			sta dropletPosY
droplet1OK:			
			rts 

testDroplet2Out:
			lda dropletPosY+2
			cmp #$ca
			bcc droplet2OK
			jsr randomize
			sta dropletPosX+2
			lda #0
			sta dropletPosY+2
droplet2OK:
			rts 

testDroplet3Out:
			lda dropletPosY+4
			cmp #$ca
			bcc droplet3OK
			jsr randomize 
			sta dropletPosX+4
			lda #0
			sta dropletPosY+4
droplet3OK:	rts 

testDroplet4Out:
			lda dropletPosY+6
			cmp #$ca 
			bcc droplet4OK
			jsr randomize 
			sta dropletPosX+6
			lda #0
			sta dropletPosY+6
droplet4OK:	rts

testDroplet5Out:
			lda dropletPosY+8
			cmp #$ca
			bcc droplet5OK
			jsr randomize
			sta dropletPosX+8
			lda #0
			sta dropletPosY+8
droplet5OK:	rts

testDroplet6Out:
			lda dropletPosY+10
			cmp #$ca
			bcc droplet6OK
			jsr randomize
			sta dropletPosX+10
			lda #0
			sta dropletPosY+10
droplet6OK:	rts 



// Randomize timer
randomize:	lda dropRand
			sta dropRandTemp 
			lda dropRand
			asl
			rol dropRandTemp
			asl
			rol dropRandTemp
			clc
			adc dropRand
			pha
			lda dropRandTemp
			adc dropRand+1
			sta dropRand+1
			pla
			adc #$11
			sta dropRand
			lda dropRand+1
			adc #$36
			sta dropRand+1
			cmp #16	// Total amount of values for new start position X. 
			bcs randomize // If range is >16 then loop randomize routine until value within range is found
			sta newpos

			ldx newpos	// Read new table position for water droplet.
			lda randPosTable,x
			rts
//---------------------------------------------------------- 

/* Game sprite to sprite collision. This can be based
   in two forms. 

   1. The slug gets the lettuce
   2. The salty water kills the slug */

spriteToSpriteCollision:

		//Store box collision co-ordinated from player sprite
		
			lda slugPosX
			sec
			sbc #spriteBoxLeft
			sta spriteColliderLeft
			clc
			adc #spriteBoxRight
			sta spriteColliderRight
			lda slugPosY
			sec
			sbc #spriteBoxTop
			sta spriteColliderTop
			clc
			adc #spriteBoxBottom
			sta spriteColliderBottom
			
			jsr slugVsLettuce
			jmp slugVsWater
			
// Collision check, slug on lettuce sprite
// if contact in range, remove lettuce 
// and score points
			
slugVsLettuce:			
			lda lettucePosX			
			cmp spriteColliderLeft			
			bcc noLettuceEaten			
			cmp spriteColliderRight 			
			bcs noLettuceEaten			
			lda lettucePosY			
			cmp spriteColliderTop			
			bcc noLettuceEaten			
			cmp spriteColliderBottom			
			bcs noLettuceEaten			
			
			// The player eats the lettuce			
				
lettuceEaten:

			jsr score500

			// No lettuce has been eaten so no			
			// collision			

//Randomize new lettuce position
randomLettucePos:
	  		lda lettuceRand
			sta lettuceRandTemp 
			lda lettuceRand
			asl
			rol lettuceRandTemp
			asl
			rol lettuceRandTemp
			clc
			adc lettuceRand
			pha
			lda lettuceRandTemp
			adc lettuceRand+1
			sta lettuceRand+1
			pla
			adc #$11
			sta lettuceRand
			lda lettuceRand+1
			adc #$36
			sta lettuceRand+1
			sta newpos2
			cmp #12				 //Total number of values for lettuce new X, Y position
			bcs randomLettucePos //if range > 12 then loop random check until matching value has been found.

			ldx newpos2			//Read table of bytes and store new X,Y position for lettuce

			lda lettuceXTable,x
			sta lettucePosX
			lda lettuceYTable,x 
			sta lettucePosY
			rts
		 							
noLettuceEaten:						
			rts			
//---------------------------------------------------------- 
						
// Score 500 points 

score500:	ldy #4
scoreLoop0:
			jsr scoreAdd
			dey 
			bpl scoreLoop0
			rts

scoreAdd:	inc score+3 
			ldx #4
scoreLoop:	lda score,x 
			cmp #$3a 
			bne scoreNotOver
			lda #$30
			sta score,x 
			inc score-1,x
scoreNotOver:
			dex
			bne scoreLoop			
			jmp updatePanel 

//---------------------------------------------------------- 

//Update score panel to display score and hi score 
//values to screen score, hi score and time 
//position 

updatePanel:
			ldx #0
putScore:	lda score,x 
			sta scoreTextPos,x 
			lda hiscore,x 
			sta hiScoreTextPos,x 
			inx 
			cpx #6 
			bne putScore

			lda time
			sta timeTextPos
			lda time+1
			sta timeTextPos2
			lda time+2
			sta timeTextPos3
			lda lives
			sta livesTextPos
			rts

//---------------------------------------------------------- 

// Collision check: Slug vs Droplets. 					

slugVsWater:

			lda slugShieldTime
			beq readWaterCollision
			rts

readWaterCollision:

			ldx #0
checkSprCol:
			lda dropletPosX,x
			cmp spriteColliderLeft
			bcc noHit
			cmp spriteColliderRight
			bcs noHit
			lda dropletPosY,x
			cmp spriteColliderTop
			bcc noHit
			cmp spriteColliderBottom
			bcs noHit
			

			jmp slugHit
noHit:			
			inx
			inx
			cpx #12
			bne checkSprCol
skipWaterCollision:			
			rts

// The slug is hit. Check if the player has more than one lives
// if so, activate a shield as its lives counter. Otherwise 
// set it to instant death.

slugHit:	lda lives
			cmp #$31 // $31 = value 1 in lives as digits
			beq lastLifeLost
					
			// Last life is not lost, so reset the 
			// shield pointer, and timer and deduct one
			// life from the counter

			lda #shieldDuration
			sta slugShieldTime
			lda #0
			sta shieldPointer
			dec lives
			jmp updatePanel

		// The last life has been lost, so set life count 
		// to zero, update the panel and destroy the slugh

lastLifeLost:
			
			lda #7
			sta $d027 
			lda #0
			sta explodeAnimDelay
			sta explodeAnimPointer		

		// Similar loop to the main game, but only exclusive
		// to the player death sequence.
exploder:
			jsr syncRaster	
			jsr waterDroplets 	
			jsr doExplosion 
			jmp exploder

		// Main slug explosion routine.

doExplosion:
			lda explodeAnimDelay
			cmp #3 
			beq doExplosion2
			inc explodeAnimDelay
			rts
doExplosion2:
			lda #0
			sta explodeAnimDelay
			ldx explodeAnimPointer
			lda explodeFrame,x 
			sta $07f8
			inx 
			cpx #explodeEnd-explodeFrame
			beq gameOver
			inc explodeAnimPointer
			rts
//---------------------------------------------------------- 

// The game is over. Remove all existing sprites
// then setup the Game Over sprites.

gameOver:	ldx #$00
clearSprScr: 
			lda #$00
			sta objPos,x 
			sta $d000,x 
			inx 
			cpx #16 // x, y ...
			bne clearSprScr


			// Game over text sprites
			lda letter_g
			sta $07f8
			lda letter_a 
			sta $07f9
			lda letter_m 
			sta $07fa
			lda letter_e
			sta $07fb 

			lda letter_o
			sta $07fc
			lda letter_v
			sta $07fd
			lda letter_e
			sta $07fe
			lda letter_r
			sta $07ff

gameOverMain:
			// Short delay ...

			ldx #$00
waste1:		ldy #$00
waste2:		iny 
			bne waste2
			inx
			bne waste1			

			// Force all sprite changable multicolour green

			ldx #$00
forceGreen:	lda #$0d
			sta $d027,x 
			inx 
			cpx #$08 
			bne forceGreen 

			// Manually setup position for Game Over sprites

			ldx #$00
posGameOver:
			lda gameOverPos,x
			sta objPos,x 
			inx 
			cpx #16
			bne posGameOver
			lda #0
			sta fireButton
			
			// Now detect whether the player's score is 
			// officially a hi score.

			lda score
			sec 
			lda hiscore+5
			sbc score+5
			lda hiscore+4
			sbc score+4
			lda hiscore+3
			sbc score+3
			lda hiscore+2
			sbc score+2
			lda hiscore+1
			sbc score+1
			lda hiscore 
			sbc score 
			bcs notAHiScore

			// Hi score achieved
hiScoreAchieved:
			ldx #$00
makeNewHi:	lda score,x 
			sta hiscore,x 
			inx 
			cpx #6 
			bne makeNewHi
			
notAHiScore:			
			jsr updatePanel

			// Keep sprites expanded and also 
			// wait for fire button for title
			// screen.

gameOverLoop:
			lda #0
			sta rp
			cmp rp
			beq *-3
			jsr expandMSB
			
			lda $dc00
			lsr
			lsr
			lsr
			lsr
			lsr
			bit fireButton
			ror fireButton
			bmi gameOverLoop
			bvc gameOverLoop
			jmp titleCode

//----------------------------------------------------------
playTime:	lda clockDelay
			cmp #$30
			beq switchCounter
			inc clockDelay
			rts
switchCounter:
			lda #0
			sta clockDelay 
			
			dec time+2
			lda time+2
			cmp #$2f
			bne clockOk
			lda #$39
			sta time+2
			dec time+1
			lda time+1
			cmp #$2f
			bne clockOk
			lda #$39 
			sta time+2
			lda #$35
			sta time+1
			dec time
			lda time 
			cmp #$2f
			bne clockOk
			lda #$30
			sta time
			sta time+1
			sta time+2
			
			jsr updatePanel
			jmp wellDone
clockOk:	jsr updatePanel
			rts		

//----------------------------------------------------------
//
// Time has run out. The slug has survived

wellDone:
			ldx #$00
clearSPR:	lda #$00
			sta $d000,x 
			inx 
			cpx #$10
			bne clearSPR
			lda letter_w
			sta $07f8
			lda letter_e 
			sta $07f9 
			lda letter_l
			sta $07fa 
			lda letter_l
			sta $07fb
			lda letter_d
			sta $07fc
			lda letter_o 
			sta $07fd
			lda letter_n
			sta $07fe
			lda letter_e
			sta $07ff
			jmp gameOverMain

//---------------------------------------------------------- 
.import source "gamepointers.asm"