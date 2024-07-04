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
    CPX #$20
    BNE LOADSPRITES

LOADBACKGROUND:
    LDA $2002
    LDA #$21
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

    LDA #$23
    STA $2006
    LDA #$D0
    STA $2006
    LDX #$00
LOADBACKGROUNDPALETTEDATA:
    LDA BACKGROUNDPALETTEDATA, X
    STA $2007
    INX
    CPX #$20
    BNE LOADBACKGROUNDPALETTEDATA

    LDA #$00
    STA $2005
    STA $2005

    CLI

    LDA #%10010000
    STA $2000
    LDA #%00011110
    STA $2001

LOOP:
    JMP LOOP

NMI:
    LDA #$02
    STA $4014
    RTI

PALETTEDATA:
	.byte $00, $0F, $00, $10, 	$00, $0A, $15, $01, 	$00, $29, $28, $27, 	$00, $34, $24, $14
	.byte $31, $0F, $15, $30, 	$00, $0F, $11, $30, 	$00, $0F, $30, $27, 	$00, $3C, $2C, $1C

SPRITEDATA:
    .byte $40, $00, $00, $40
	.byte $40, $01, $00, $48
	.byte $48, $10, $00, $40
	.byte $48, $11, $00, $48

    .byte $50, $08, %00000001, $80
	.byte $50, $08, %01000001, $88
	.byte $58, $18, %00000001, $80
	.byte $58, $18, %01000001, $88

BACKGROUNDDATA:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$00,$00,$00,$00,$00,$00,$00,$06,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$08,$09,$0a,$0b,$0b,$0b,$0c,$0d,$0e,$0f,$10,$11,$56,$13,$14,$0b,$15,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$16,$17,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$19,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$1a,$1b,$1c,$1d,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$1e,$06,$1f,$00,$00,$00,$00,$00
	.byte $00,$00,$20,$21,$22,$23,$18,$24,$25,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$26,$27,$28,$00,$29,$2a,$00,$00,$00,$00,$00
	.byte $00,$00,$2b,$2c,$2d,$0b,$11,$2e,$2f,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$30,$31,$32,$33,$34,$35,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$36,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$18,$37,$38,$39,$3a,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$3c,$3d,$3e,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$3f,$40,$0b,$0b,$0b,$41,$42,$43,$44,$0b,$0b,$45,$0b,$0b,$0b,$0b,$46,$47,$48,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$49,$0b,$0b,$4a,$4b,$00,$4c,$4d,$0b,$4e,$4f,$50,$0b,$0b,$51,$00,$52,$53,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$3f,$54,$55,$12,$00,$00,$00,$57,$58,$59,$00,$5a,$5b,$5c,$5d,$00,$5e,$5f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$60,$61,$00,$00,$62,$63,$64,$65,$00,$66,$67,$68,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$69,$00,$00,$6a,$6b,$6c,$00,$6d,$6e,$6f,$70,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$71,$72,$73,$0b,$74,$75,$76,$77,$78,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$79,$7a,$7b,$7c,$7d,$7e,$7f,$80,$81,$82,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4c,$83,$84,$85,$86,$35,$87,$00,$00,$00,$00,$00,$00

BACKGROUNDPALETTEDATA:
    .byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
	.byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55



.segment "VECTORS"
    .word NMI
    .word RESET
    
.segment "CHARS"
    .incbin "rom.chr"