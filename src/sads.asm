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

        SECTION "Main Code",HOME

FirstTime:
        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a

        call    Player_Initialize       ; Initialize sound registers and
                                        ; player variables on startup

NewSong:
        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a

        call    Player_MusicStart       ; Start music playing

        ld      a,SongNumber            ; Call SongSelect AFTER MusicStart!
        call    Player_SongSelect       ; (Not needed if SongNumber = 0)


FrameLoop:
        ld      c,$10                   ; Waiting
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

        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicUpdate      ; Call this once a frame

        ld      a,FxBank                ; Switch to FXBank
        ld      [rROMB0],a
        call    SoundFX_Update          ; Call this once a frame too
        

        ld      c,$90                   ; Waiting
        call    WaitLCDLine

        jr      FrameLoop



StopExample:
        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicStop        ; Stops reading note data and cuts
                                        ; all music notes currently playing

        ld      a,FxBank                ; Switch to FXBank
        ld      [rROMB0],a
        call    SoundFX_Stop            ; Stop any sound FX playing

        ret


TrigSoundFXExample:
        ld      a,FxBank                ; Switch to FXBank
        ld      [rROMB0],a
        ld      a,1
        call    SoundFX_Trig            ; Trig sound FX number 2

        ret

TrigSoundFXExample1:
        ld      a,FxBank                ; Switch to FXBank
        ld      [rROMB0],a
        ld      a,2
        call    SoundFX_Trig            ; Trig sound FX number 2

        ret

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

        ds      $30                     ; $c7c0 - $c7ef for player variables
