.segment "HEADER"                                   ; NES 2.0 Rom Format
    .byte "NES"                                     ; 0-2 First 4 bytes must be "NES"
    .byte $1A                                       ;   3 and <EOF> aka. $1A
    .byte $02                                       ;   4 LSB of PRG-ROM size in 16KiB units
    .byte $01                                       ;   5 LSB of CHR-ROM size in 8KiB units
    .byte $00                                       ;   Flags 6 - 15
    .byte $00, $00, $00, $00                        ;   Too difficult to understand now...
    .byte $00, $00, $00, $00, $00

.segment "ZEROPAGE"                                 ; Declare variable at ZEROPAGE segment

.segment "STARTUP"                                  ; STARTUP segment is where the code is placed
RESET:                  ; RESET is triggered when the console is turned on or reset
    SEI                 ; Disables interrupts from happening
    CLD                 ; Clears decimal mode, not useful
    LDX #$40
    STX $4017           ; Disable APU IRQ
    LDX #$00
    STX $4010           ; Disable PCM

    LDX #$FF
    TXS                 ; Initializa SR at $FF

    LDX #$00            
    STX $2000
    STX $2001           ; Clear the PPU Controller and Mask

:
    BIT $2002           ; $2002 7th bit is on 0 if not in vblank
    BPL :-              ; check if not in vblank

    TXA
CLEARMEMORY:
    STA $0000, X
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FF
    STA $0200, X
    LDA #$00
    INX
    CPX #$00
    BNE CLEARMEMORY

    PLAYER_SPRITE1_Y = $0200
    PLAYER_SPRITE1_X = $0203
    PLAYER_SPRITE2_Y = $0204
    PLAYER_SPRITE2_X = $0207
    PLAYER_SPRITE3_Y = $0208
    PLAYER_SPRITE3_X = $020B
    PLAYER_SPRITE4_Y = $020C
    PLAYER_SPRITE4_X = $020F
    PLAYER_SPRITE5_Y = $0210
    PLAYER_SPRITE5_X = $0213
    PLAYER_SPRITE6_Y = $0214
    PLAYER_SPRITE6_X = $0217
:
    BIT $2002
    BPL :-

    LDA #$02
    STA $4014
    NOP

    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
LOADPALETTES:
    LDA PALETTEDATA, X
    STA $2007
    INX
    CPX #$20
    BNE LOADPALETTES

    LDX #$00
LOADSPRITES:
    LDA SPRITEDATA, X
    STA $0200, X
    INX
    CPX #$30
    BNE LOADSPRITES

LOADBACKGROUND:
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
LOADBACKGROUNDP1:
    LDA BACKGROUNDDATA, X
    STA $2007
    INX
    CPX #$00
    BNE LOADBACKGROUNDP1
LOADBACKGROUNDP2:
    LDA BACKGROUNDDATA+256, X
    STA $2007
    INX
    CPX #$00
    BNE LOADBACKGROUNDP2
LOADBACKGROUNDP3:
    LDA BACKGROUNDDATA+512, X
    STA $2007
    INX
    CPX #$00
    BNE LOADBACKGROUNDP3
LOADBACKGROUNDP4:
    LDA BACKGROUNDDATA+768, X
    STA $2007
    INX
    CPX #$F0
    BNE LOADBACKGROUNDP4

    LDA $2002
    LDA #$23
    STA $2006
    LDA #$C0
    STA $2006
    LDX #$00
LOADBACKGROUNDPALETTEDATA:
    LDA BACKGROUNDPALETTEDATA, X
    STA $2007
    INX
    CPX #$80
    BNE LOADBACKGROUNDPALETTEDATA

    LDA #$00
    STA $2005
    STA $2005

    CLI

    LDA #%10010000
    STA $2000
    LDA #%00011110
    STA $2001

READCONTROLLER:
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016

    LDA $4016 ; Player 1 - A
    LDA $4016 ; Player 1 - B
    LDA $4016 ; Player 1 - SELECT
    LDA $4016 ; Player 1 - START

    LDA $4016 ; Player 1 - UP
    AND #%000000001
    BEQ ENDREADINGUP
    LDA PLAYER_SPRITE1_Y
    SEC
    SBC #$01
    STA PLAYER_SPRITE1_Y
    STA PLAYER_SPRITE2_Y
    STA PLAYER_SPRITE3_Y

    LDA PLAYER_SPRITE4_Y
    SEC
    SBC #$01
    STA PLAYER_SPRITE4_Y
    STA PLAYER_SPRITE5_Y
    STA PLAYER_SPRITE6_Y
ENDREADINGUP:

    LDA $4016 ; Player 1 - DOWN
    AND #%000000001
    BEQ ENDREADINGDOWN
    LDA PLAYER_SPRITE1_Y
    CLC
    ADC #$01
    STA PLAYER_SPRITE1_Y
    STA PLAYER_SPRITE2_Y
    STA PLAYER_SPRITE3_Y

    LDA PLAYER_SPRITE4_Y
    CLC
    ADC #$01
    STA PLAYER_SPRITE4_Y
    STA PLAYER_SPRITE5_Y
    STA PLAYER_SPRITE6_Y
ENDREADINGDOWN:

    LDA $4016 ; Player 1 - LEFT
    AND #%000000001
    BEQ ENDREADINGLEFT
    LDA PLAYER_SPRITE1_X
    SEC
    SBC #$01
    STA PLAYER_SPRITE1_X
    STA PLAYER_SPRITE4_X

    LDA PLAYER_SPRITE2_X
    SEC
    SBC #$01
    STA PLAYER_SPRITE2_X
    STA PLAYER_SPRITE5_X

    LDA PLAYER_SPRITE3_X
    SEC
    SBC #$01
    STA PLAYER_SPRITE3_X
    STA PLAYER_SPRITE6_X
ENDREADINGLEFT:

    LDA $4016 ; Player 1 - RIGHT
    AND #%000000001
    BEQ ENDREADINGRIGHT
    LDA PLAYER_SPRITE1_X
    CLC
    ADC #$01
    STA PLAYER_SPRITE1_X
    STA PLAYER_SPRITE4_X

    LDA PLAYER_SPRITE2_X
    CLC
    ADC #$01
    STA PLAYER_SPRITE2_X
    STA PLAYER_SPRITE5_X

    LDA PLAYER_SPRITE3_X
    CLC
    ADC #$01
    STA PLAYER_SPRITE3_X
    STA PLAYER_SPRITE6_X
ENDREADINGRIGHT:

    RTS


LOOP:
    JMP LOOP

NMI:
    LDA #$02
    STA $4014

    JSR READCONTROLLER

    RTI

PALETTEDATA:
	.byte $0F,$0F,$0F,$0F, $0F,$06,$15,$36, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F
	.byte $0F,$21,$15,$30, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F, $0F,$0F,$0F,$0F

SPRITEDATA:
    .byte $80, $0A, $00, $80
    .byte $80, $0B, $00, $88
    .byte $80, $0C, $00, $90
    .byte $88, $0D, $00, $80
    .byte $88, $0E, $00, $88
    .byte $88, $0F, $00, $90

BACKGROUNDDATA:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01

    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
    .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03

BACKGROUNDPALETTEDATA:
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00


.segment "VECTORS"
    .word NMI
    .word RESET
    
.segment "CHARS"
    .incbin "graphics.chr"