Player_Initialize       equ     $4000
Player_MusicStart       equ     $4003
Player_MusicStop        equ     $4006
Player_SongSelect       equ     $400c
Player_MusicUpdate      equ     $4100

SoundFX_Trig            equ     $4000
SoundFX_Stop            equ     $4003
SoundFX_Update          equ     $4006

MusicBank               equ     1
FxBank                  equ     3
Effect1                 equ     1
Effect2                 equ     2

SongNumber              equ     0       ; 0 - 7

INCLUDE "hardware.inc"

        SECTION "Paradise", HOME
INCLUDE "gfx/monkey.inc"

        SECTION "Org $100",HOME[$100]

;*** Beginning of rom execution point ***

        nop
        jp      FirstTime

        NINTENDO_LOGO                   ; Nintendo graphic logo

;Rom Header Info

;    0123456789ABCDE
 DB "CARILLON TEST"         ; Cart name   16bytes
 DB $80                       ; GBC=$80
 DB 0,0,0
 DB CART_ROM                  ; Cart type
 DB CART_ROM_256K             ; ROM Size (in bits)
 DB CART_RAM_NONE             ; RAM Size (in bits)
 DB 1,1
 DB 0
 DB $e2                       ; Complement check (important)
 DW $c40e                     ; Checksum (not important)


INCLUDE "src/KEYPAD.ASM"
INCLUDE "src/memory.asm"

        SECTION "Main Code",HOME



FirstTime:
        ld      a,0                             ; SET SCREEN TO TO UPPER RIGHT HAND CORNER
        ld      [rSCX], a
        ld      [rSCY], a       
        call    LCDOff      
        ld      a, %11100100                    ; Window palette colors, from darkest to lightest
        ld      [rBGP], a                       
        
        ld      hl,monkey_tile_data               
        ld      de, _VRAM                       ; _VRAM=$8000=tile pattern table 0. 
        ld      bc,monkey_tile_count*16
        call    mem_Copy                        ; load tile data

        ld      hl,monkey_map_data         
        ld      de, _SCRN0+0+(SCRN_VY_B)      
        ld      bc, monkey_tile_map_size
        call    mem_CopyVRAM 
        call    LCDOn

        ld      a,MusicBank                     ; Switch to MusicBank
        ld      [rROMB0],a
        
        call    Player_Initialize               ; Initialize sound registers and
                                                ; player variables on startup

NewSong:
        ld      a,MusicBank                     ; Switch to MusicBank
        ld      [rROMB0],a

        call    Player_MusicStart               ; Start music playing

        ld      a,SongNumber                    ; Call SongSelect AFTER MusicStart!
        call    Player_SongSelect               ; (Not needed if SongNumber = 0)

      
FrameLoop:
        ld      c,$10                           ; Waiting
        call    WaitLCDLine

        call    pad_Read
        bit     PADB_UP,a
        jr      z,CheckDown
        call    TrigSoundFXExample
CheckDown:
        bit     PADB_DOWN,a
        jr      z,NotPressed
        call    TrigSoundFXExample1
NotPressed: 

        ld      a,MusicBank                     ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicUpdate              ; Call this once a frame

        ld      a,FxBank                        ; Switch to FXBank
        ld      [rROMB0],a
        call    SoundFX_Update                  ; Call this once a frame too
        

        ld      c,$90                           ; Waiting
        call    WaitLCDLine

        jr      FrameLoop


StopExample:
        ld      a,MusicBank                     ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicStop                ; Stops reading note data and cuts
                                                ; all music notes currently playing

        ld      a,FxBank                        ; Switch to FXBank
        ld      [rROMB0],a
        call    SoundFX_Stop                    ; Stop any sound FX playing

        ret


TrigSoundFXExample:
        ld      a,FxBank                        ; Switch to FXBank
        ld      [rROMB0],a
        ld      a,1
        call    SoundFX_Trig                    ; Trig sound FX number 2

        ret
WAIT_VBLANK:
        ldh     a,[rLY]                         ;get current scanline
        cp      $91                             ;Are we in v-blank yet?
        jr      nz,WAIT_VBLANK                  ;if A-91 != 0 then loop
        ret                                     ;done

TrigSoundFXExample1:
        ld      a,FxBank                        ; Switch to FXBank
        ld      [rROMB0],a
        ld      a,2
        call    SoundFX_Trig                    ; Trig sound FX number 2

        ret
LCDOff:
        call WAIT_VBLANK
        ldh a, [rLCDC]
        and $7F
        ldh [rLCDC], a
        ret

LCDOn:
        di
        ldh a, [rLCDC]
        or $80
        ldh [rLCDC], a
        call WAIT_VBLANK
        xor a
        ldh [rIF], a
        reti

WaitLCDLine:
        ld      a,[rLY]
        cp      c
        jr      nz,WaitLCDLine

        ret



        SECTION "Music",DATA[$4000],BANK[MusicBank]

        INCBIN "snd/fruitless.bin"              ; player code and music data


        SECTION "FX",DATA[$4000],BANK[FxBank]

        INCBIN "snd/fxbank.bin"


        SECTION "Reserved",BSS[$c7c0]

        ds      $30                             ; $c7c0 - $c7ef for player variables
