SECTION "code", ROM0[$100]

; ld [\1], hl
MACRO LD_IND_HL
	db $22, (\1 & $FF), (\1 >> 8)
	ENDM
; ld hl, [\1]
MACRO LD_HL_IND
	db $2A, (\1 & $FF), (\1 >> 8)
	ENDM
; ld de, hl
MACRO LD_DE_HL
    ld d, h
    ld e, l
ENDM

MACRO ERAPI_Call0
    rst 0
    db \1
ENDM

; ERAPI_GetKeyState
; Returns pressed keys in hl
MACRO ERAPI_GetKeyState
    LD_HL_IND 0xC2
ENDM

DEF ERAPI_KEY_A      = 0x01

MACRO ERAPI_CallSetBackgroundMode
    ERAPI_Call0 0x19
ENDM

; ERAPI_SetBackgroundMode()
; a = mode (0-2)
MACRO ERAPI_SetBackgroundMode	
    ld a, \1
    ERAPI_CallSetBackgroundMode
ENDM

MACRO ERAPI_CallLoadSystemBackground
    ERAPI_Call0 0x10
ENDM

; ERAPI_LoadSystemBackground()
; e = layer (0-3)
; a = index (1-101)
MACRO ERAPI_LoadSystemBackground
    ld e, \1 
    ld a, \2
    ERAPI_CallLoadSystemBackground
ENDM

MACRO ERAPI_CallFadeIn
    ERAPI_Call0 0x00
ENDM

; ERAPI_FadeIn()
; a = number of frames
MACRO ERAPI_FadeIn
    ld  a, \1 
    ERAPI_CallFadeIn
ENDM

MACRO ERAPI_CallDrawNumber
    ERAPI_Call0 0x6B
ENDM

; ERAPI_DrawNumber()
; hl = pointer to number struct 
MACRO ERAPI_DrawNumber
    ld hl, \1
    ERAPI_CallDrawNumber
ENDM

MACRO ERAPI_CallDrawNumberNewValue
    ERAPI_Call0 0x6C
ENDM

; ERAPI_DrawNumberNewValue()
; hl = pointer to number struct 
; de = new number to set
MACRO ERAPI_DrawNumberNewValue
    ld hl, \1
    ld de, \2
    ERAPI_CallDrawNumberNewValue
ENDM

main:
    call main_init

main_loop:
    call main_tick

    ; wait for one frame
    ld a, 0x01
    halt

    ; loop
    jr main_loop


main_init:
    ; Setup the background
    ERAPI_SetBackgroundMode 0x00
    ERAPI_LoadSystemBackground 2, 9

    ; Fade in over 0 frames
    ERAPI_FadeIn 0x00
 
    ; Draw the number
    ERAPI_DrawNumber sprite

    ret

main_tick:
    ; read current keys into hl
    ERAPI_GetKeyState
    
    ; move low key byte into a then check if keys pressed
    ld a, l
    and a, ERAPI_KEY_A
    jr nz, key_a_pressed

    ; none pressed
    ret

key_a_pressed:
    ; hl = count
    LD_HL_IND count
    ; hl = hl + 1
    inc hl
    ; count = hl
    LD_IND_HL count
    ; redraw
    ; de = hl
    LD_DE_HL
    ; hl = sprite pointer
    ld hl, sprite
    ERAPI_CallDrawNumberNewValue

    ret


; sprite for the total
sprite:
    db 0x01   ; background index
    db 0x00   ; palette index
    db 0x07   ; x in tiles
    db 0x08   ; y in tiles
    dw 0x1029 ; system id for the font
    db 0x05   ; max number of digits
    db 0x00   ; additional right pad zeros
    db 0x01   ; zero fill empty digits? 0 -> no, 1 -> yes
    db 0x00   ; ??????
count: 
    dw 0x0000 ; Value to draw
