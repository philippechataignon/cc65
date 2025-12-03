;
; Oliver Schmidt, 2009-09-15
;
; Startup code for cc65 (Apple2 version)
;

        .export         done
        .export         __STARTUP__ : absolute = 1      ; Mark as startup

        .import         initlib, donelib
        .import         zerobss, callmain
        .import         __ONCE_LOAD__, __ONCE_SIZE__    ; Linker generated

        .include        "zeropage.inc"
        .include        "apple2.inc"

; ------------------------------------------------------------------------

        .segment        "STARTUP"

        ; Save space by putting some of the start-up code in the ONCE segment,
        ; which can be re-used by the BSS segment, the heap and the C stack.
        jsr     init

        ; Clear the BSS data.
        jsr     zerobss

        ; Push the command-line arguments; and, call main().
        jsr     callmain

        ; Call the module destructors.
        jsr     donelib

        ; Copy back the zero-page stuff.
        ldx     #zpspace-1
:       lda     zpsave,x
        sta     sp,x
        dex
        bpl     :-

        ; We're done
done:   rts

; ------------------------------------------------------------------------

        .segment        "ONCE"

        ; Save the zero-page locations that we need.
init:   ldx     #zpspace-1
:       lda     sp,x
        sta     zpsave,x
        dex
        bpl     :-

basic:  lda     HIMEM
        ldx     HIMEM+1

        ; Set up the C stack.
        sta     sp
        stx     sp+1

        ; Call the module constructors.
        jsr     initlib

        ; Set the source start address.
        lda     #<(__ONCE_LOAD__ + __ONCE_SIZE__)
        ldy     #>(__ONCE_LOAD__ + __ONCE_SIZE__)
        sta     $9B
        sty     $9C
        rts

; ------------------------------------------------------------------------

        .data

; ------------------------------------------------------------------------

        .segment        "INIT"

zpsave: .res    zpspace
