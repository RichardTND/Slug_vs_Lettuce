//--------------------------------
//Slug vs Lettuce
//by Richard Bayliss
//(C)2022 Scene World - Issue 32
//--------------------------------

//Some one time code (After running main program at $1000)

oneTime:       
               lda #251    // Disable RUN/STOP and RESTORE
               sta $0328   // throughout

/* One time PAL/NTSC checker routine. This
   is used to check the raster position of 
   the default screen. */

               lda $d012         //Raster line on C64 machine
               cmp $d012 
               beq *-3
               bmi oneTime
               cmp #$22          // If rasterline is below then C64 is NTSC
               bcc ntscDetected

               // System PAL has been detected

palDetected:   lda #1            // Otherwise it is just PAL
               sta system
               lda #$30          // Set delay value of clock
               sta timeExpiry

               jmp titleCode     // Start main title screen


               // System NTSC has been detected

ntscDetected:  lda #0
               sta system
               lda #$40          // Set delay of clock to higher rate as NTSC is much faster
               sta timeExpiry

//---------------------------------------------------------
              
// Title screen code
// Switch off all IRQ raster interrupts, sprites, etc. 

titleCode:
                sei
                ldx #$31
                ldy #$ea
                lda #$81
                stx $0314
                sty $0315
                sta $dc0d
                sta $dd0d 
                lda #$0b
                sta $d011
                lda #0
                sta $d015
                sta $d020
                sta $d021
                sta flashDelay 
                sta flashPointer

// Silence SID chip once again

                ldx #$00
silentSidTitle: lda #$00
                sta $d400,x 
                inx 
                cpx #$18 
                bne silentSidTitle               

// Setup title screen graphics 

                lda #$1c   // Game+Title charset at $3800
                sta $d018               
                lda #$09   // Setup background multicolour brown
                sta $d022
                lda #$01   // Setup background multicolour white
                sta $d023

// Clear the screen once

                ldx #$00   
titleClear:     lda #$20
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $06e8,x
                inx
                bne titleClear

/* Draw the title screen logo data by reading the logo
   matrix and placing it onto the default screen RAM
   (at )$0400-$07e8) */

                ldx #$00
drawLogo:       lda logoMatrix,x 
                sta $0400+(2*40),x 
                lda logoMatrix+(1*40),x
                sta $0400+(3*40),x
                lda logoMatrix+(2*40),x
                sta $0400+(4*40),x 
                lda logoMatrix+(3*40),x
                sta $0400+(5*40),x
                lda logoMatrix+(4*40),x
                sta $0400+(6*40),x
                lda logoMatrix+(5*40),x
                sta $0400+(7*40),x
                lda logoMatrix+(6*40),x
                sta $0400+(8*40),x
                inx 
                cpx #40 
                bne drawLogo

// Draw second segment of logo 

                ldx #$00
drawLogo2:      lda logoMatrix+(7*40),x
                sta $0400+(9*40),x
                lda logoMatrix+(8*40),x
                sta $0400+(10*40),x 
                lda logoMatrix+(9*40),x
                sta $0400+(11*40),x
                lda logoMatrix+(10*40),x
                sta $0400+(12*40),x
                inx 
                cpx #40 
                bne drawLogo2

                // Updated score and hi scores 

                ldx #$00
updaateScoreData:
                lda score,x
                sta lastScore,x
                lda hiscore,x
                sta newHiScore,x
                inx
                cpx #6
                bne updaateScoreData


                // Now put scoreline at top row and credits text

                ldx #$00
copyScoreLine:  lda scoreLine,x
                sta $0400,x
                lda line1,x
                sta $0400+(14*40),x 
                lda line2,x
                sta $0400+(16*40),x
                lda line3,x
                sta $0400+(17*40),x 
                lda line4,x
                sta $0400+(19*40),x
                lda line5,x 
                sta $0400+(21*40),x
                inx 
                cpx #$28
                bne copyScoreLine

                // Grab the game's colour attributes table and place to screen colour RAM

                ldx #$00
fetchAttribsT:  ldy $0400,x 
                lda gameAttribs,y 
                sta $d800,x
                ldy $0500,x 
                lda gameAttribs,y 
                sta $d900,x
                ldy $0600,x
                lda gameAttribs,y 
                sta $da00,x
                ldy $06e8,x 
                lda gameAttribs,y 
                sta $dae8,x
                inx
                bne fetchAttribsT

        
                // Paint the scroll text colour 

                ldx #$00
putScrollColour:
                lda #$03
                sta $d800,x
                lda scrollColour,x 
                sta $dbc0,x 
                inx 
                cpx #40 
                bne putScrollColour

                /* Waste some time for a short delay. (In order)
                   to reduce sensitivity with the fire button 
                   everytime a game has been completed or lost 
                */

                ldx #$00
tDelay1:        ldy #$00
tDelay2:        iny
                bne tDelay2
                inx
                bne tDelay1

                // Reset firebutton pointer

                lda #0 
                sta fireButton 

                // Reset scrolltext message

                lda #<scrollText
                sta messRead+1
                lda #>scrollText
                sta messRead+2

//-------------------------------------------------------------

// Setup IRQ raster interrupts 

                ldx #<tIRQ1
                ldy #>tIRQ1 
                lda #$7f 
                stx $0314
                sty $0315
                sta $dc0d
                lda #$2e
                sta $d012
                lda #$1b
                sta $d011
                lda #$01
                sta $d01a
                lda #titleMusic
                jsr musicInit
                cli 
                jmp titleLoop

// Main IRQ interrupts

                // Setup smooth scrolling hardware scroll at bottom raster position

tIRQ1:          inc $d019
                lda $dc0d
                sta $dd0d
                lda #$2e
                sta $d012 
                lda xpos
                sta $d016 
                ldx #<tIRQ2 
                ldy #>tIRQ2
                stx $0314
                sty $0315
                jmp $ea7e

                // Set static multicolour screen in top raster value
tIRQ2:          inc $d019 
                lda #$f0
                sta $d012 
                lda #$18
                sta $d016
                lda #1           // Control raster position 
                sta rp 
                jsr musicPlayer  // Call PAL/NTSC music speed player in gamecode.asm
                                 // since all tunes and jingles are shared in the same
                                 // music file.
                ldx #<tIRQ1                 
                ldy #>tIRQ1
                stx $0314
                sty $0315
                jmp $ea7e 

//----------------------------------------------------

/* The main loop for the title screen. First check 
   the raster position and then run the scroll text,
   flash the press fire text, also wait for the fire
   button to be pressed before starting a new game */

titleLoop:      lda #0
                sta rp
                cmp rp
                beq *-3

                jsr scrollRoutine
                jsr flashRoutine
                lda $dc00
                lsr
                lsr
                lsr
                lsr
                lsr
                bit fireButton
                ror fireButton
                bmi titleLoop
                bvc titleLoop
                jmp gameCode

// ----------------------------------------------------

// Title screen scroll text routine

scrollRoutine:
                lda xpos   // Our scroll pointer
                sec        // pull pointer back
                sbc #2     // max speed of scroll
                and #7     // single colour 
                sta xpos   
                bcs exitScroll

                // Shift scrolling message text back one space (Max, 40 characters)

                ldx #$00
moveText:       lda $07c1,x
                sta $07c0,x
                inx
                cpx #$28
                bne moveText 

               // Scroll text message control. Checks which byte has to be read 
               // and if @ is found then reset the scroll text.

messRead:       lda scrollText 
                bne storeChar
                lda #<scrollText 
                sta messRead+1
                lda #>scrollText 
                sta messRead+2
                jmp messRead

               // ... otherwise place the character of the message in the last column

storeChar:      sta $07e7

               // ... read next character of scroll text message 

                inc messRead+1
                bne exitScroll
                inc messRead+2
exitScroll:     rts

// ----------------------------------------------------

// Flash routine for PRESS FIRE TO START  

               // Control speed of flashing

flashRoutine:   lda flashDelay
                cmp #3
                beq flashOk
                inc flashDelay
                rts

               // Main flashing routine

flashOk:        lda #0
                sta flashDelay
                ldx flashPointer    // Read pointer position
                lda flashColour,x   // Read colour table
                sta flashStore      // Place into store pointer
                inx                 // move to next byte on table
                cpx #10             // 10 bytes read?
                beq resetFlasher    // reset the flash pointer to 0
                inc flashPointer
                jmp paintFirePrompt      

                // Reset flash pointer

resetFlasher:   ldx #0
                stx flashPointer

                // Read pointer flashStore and place it over the
                // PRESS FIRE TO PLAY text.
paintFirePrompt:
                ldy #$00
paintFireLoop:
                lda flashStore 
                sta $db48,y 
                iny 
                cpy #40
                bne paintFireLoop
                rts

// Title screen pointers

xpos:           .byte 0 // Smooth/hard scroll controller
flashDelay:     .byte 0 // Flashing speed pointer
flashPointer:   .byte 0 // Flashing colour pointer
flashStore:     .byte 0 // Colour storage from table

// Self=modified score/hi score text and static presentation lines

scoreLine:  
              .text "last score: "
lastScore:    .text "000000     hi score: "
newHiScore:      .text "000000"

               // Main presentation lines

line1:         .text "         £ scene world magazine         "
line2:         .text " code, graphics and sound and music by  "
line3:         .text "             richard bayliss            "
line4:         .text "      plug a joystick into port 2       "
line5:         .text "         - press fire to play -         "

// Title screen scroll text colour 

scrollColour:   .byte $09,$08,$0a,$07,$01   // Scroll text colour = 40 chars
                .byte $01,$01,$01,$01,$01
                .byte $01,$01,$01,$01,$01
                .byte $01,$01,$01,$01,$01
                .byte $01,$01,$01,$01,$01
                .byte $01,$01,$01,$01,$01
                .byte $01,$01,$01,$01,$01
                .byte $07,$0a,$08,$09,$09

                // PRESS FIRE flash colour table

flashColour:    .byte $02,$04,$03,$07,$01
                .byte $07,$03,$04,$02,$00

               // Main title screen scroll text

scrollText: .text "   ... slug vs lettuce ...   yet another fast and fun little game production for your c64 ...    this game was designed, programmed and developed by richard bayliss ...   £ 2022 "
            .text "scene world magazine ...   written as part of the game programming tutorial "
            .byte $22
            .text "let's make a c64 game"
            .byte $22
            .text " ...   please read scene world issue 32 to find out more about it ...   "
            .text "how to play: this is a simple little single screen platform hi score challenge ...   this game "
            .text "requires a joystick in port 2 ...    guide your speedy slug around the cave and eat the lettuce that appears on "
            .text "screen ...   you can use left/right to move your slug its directions, also use the fire button to make it jump ...   "
            .text "watch out for the deadly water droplets ...   if they hit your slug, you will lose a life ...    when your slug "
            .text "is flashing, you are protected for a bit ...   you will gain an extra life for every minute of survival (unless you still have 9 lives) ...   "
            .text "if the time runs out, you have won the game ...    the game is lost if you lose all of your lives ...    "
            .text "the graphics were designed using charpad v2.7.6, and the sprites were made using sprite pad v2.0 ...   music was "
            .text "made using goat tracker ultra v1.2.0 ...   the rest was compiled and put together in kickassembler (via visual studio code), exomizer v3.1.1 and "
            .text "vice ...    i do hope you have loads of fun playing this game production, and i shall see you some other time "
            .text "with yet another new c64 game production, but it could be a long while yet ...    press fire to play ...      "
            .text "                                              "
            .byte 0