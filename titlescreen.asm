//--------------------------------
//Slug vs Lettuce
//by Richard Bayliss
//(C)2022 Scene World - Issue 32
//--------------------------------

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

 // Silence SID chip once again

                ldx #$00
silentSidTitle: lda #$00
                sta $d400,x 
                inx 
                cpx #$18 
                bne silentSidTitle               

 // Setup title screen graphics 

                lda #$1c
                sta $d018               
                lda #$18
                sta $d016
                lda #$09
                sta $d022
                lda #$01
                sta $d023

                ldx #$00
titleClear:     lda #$20
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $06e8,x
                inx
                bne titleClear

 // Draw the title screen logo data

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

                // Updated score and hi score 

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

                // Grab the game's attributes table and place to screen colour RAM

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


                // Waste some time
                ldx #$00
tDelay1:        ldy #$00
tDelay2:        iny
                bne tDelay2
                inx
                bne tDelay1

                // Reset firebutton 

                lda #0 
                sta fireButton 

                // Reset scrolltext 

                lda #<scrollText
                sta messRead+1
                lda #>scrollText
                sta messRead+2

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
                lda #0
                jsr musicInit
                cli 
                jmp titleLoop

// Main IRQ interrupts

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

tIRQ2:          inc $d019 
                lda #$f0
                sta $d012 
                lda #$18
                sta $d016
                lda #1
                sta rp 
                jsr musicPlay
                ldx #<tIRQ1                 
                ldy #>tIRQ1
                stx $0314
                sty $0315
                jmp $ea7e 

//----------------------------------------------------

titleLoop:      lda #0
                sta rp
                cmp rp
                beq *-3

                jsr scrollRoutine
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

scrollRoutine:
                lda xpos
                sec
                sbc #1 
                and #7
                sta xpos
                bcs exitScroll

                ldx #$00
moveText:       lda $07c1,x
                sta $07c0,x
                inx
                cpx #$27
                bne moveText 

messRead:       lda scrollText 
                bne storeChar
                lda #<scrollText 
                sta messRead+1
                lda #>scrollText 
                sta messRead+2
                jmp messRead

storeChar:      sta $07e7

                inc messRead+1
                bne exitScroll
                inc messRead+2
exitScroll:     rts


// Presentation lines

xpos:           .byte 0

scoreLine:  
              .text "last score: "
lastScore:    .text "000000     hi score: "
newHiScore:      .text "000000"

line1:         .text "          (c)2022 scene world          "
line2:         .text " code, graphics and sound and music by "
line3:         .text "            richard bayliss            "
line4:         .text "        use joystick in port 2         "
line5:         .text "        - press fire to play -         "

// Title screen scroll text

scrollText: .text "   ... slug vs lettuce ...   (c) 2022 scene world magazine ...    brought to you by "
            .text "people of liberty and the new dimension ...   programming, graphics, sound and music were "
            .text "all done by richard bayliss ...   plug a joystick into port 2 ...    how to play: "
            .text "this is a fun little game involving a slug, lettuce, platforms and salty water "
            .text "...   the aim of this game is to help feed the slug lettuce, which will appear "
            .text "at random onto one of the platforms or the ground surface of the cave ...   by eating "
            .text "the lettuce, you will score 500 points ...   left and right moves your slug and "
            .text "pressing fire will allow the slug to jump "
            .text "from one platform to another only when reachable ...   watch out for the salt water droplets, which "
            .text "are leaking inside the cave ...   if you get hit by one of those, you will lose a life ...   "
            .text "as soon as all of your lives are gone, the game is over ...   try to survive for about ten "
            .text "minutes to win the game, but keep on scoring those precious points while you can ...   "
            .text "have loads of fun ...    bye for now !!!                                             "
            .byte 0