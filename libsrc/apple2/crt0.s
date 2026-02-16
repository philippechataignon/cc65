;
; Oliver Schmidt, 2009-09-15
;
; Startup code for cc65 (Apple2 version)
;

        .export         done
        .export         __STARTUP__ : absolute = 1      ; Mark as startup

        .import         zerobss
        .import         _main

        .include        "zeropage.inc"
        .include        "apple2.inc"

; ------------------------------------------------------------------------

        .segment        "STARTUP"

        lda     HIMEM
        ldx     HIMEM+1

        ; Set up the C stack.
        sta     sp
        stx     sp+1

        ; Clear the BSS data.
        jsr     zerobss

        ; Push the command-line arguments; and, call main().
        ; jsr     callmain
        jmp _main

done:   rts


        .segment        "ONCE"
        .segment        "INIT"
