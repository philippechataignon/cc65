;
; Oliver Schmidt, 2009-09-15
;
; Startup code for cc65 (Apple2 version)
;

        .export         _exit, done, return
        .export         __STARTUP__ : absolute = 1      ; Mark as startup

        .import         initlib, donelib
        .import         zerobss, callmain
        .import         __ONCE_LOAD__, __ONCE_SIZE__    ; Linker generated
        .import         __LC_START__, __LC_LAST__       ; Linker generated

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

        ; Avoid a re-entrance of donelib. This is also the exit() entry.
_exit:  ldx     #<exit
        lda     #>exit
        jsr     reset           ; Setup RESET vector

        ; Call the module destructors.
        jsr     donelib

        ; Restore the original RESET vector.
exit:   ldx     #$02
:       lda     rvsave,x
        sta     SOFTEV,x
        dex
        bpl     :-

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

        ; Save the original RESET vector.
        ldx     #$02
:       lda     SOFTEV,x
        sta     rvsave,x
        dex
        bpl     :-

basic:  lda     HIMEM
        ldx     HIMEM+1

        ; Set up the C stack.
        sta     sp
        stx     sp+1

        ; ProDOS TechRefMan, chapter 5.3.5:
        ; "Your system program should place in the RESET vector the
        ;  address of a routine that ... closes the files."
        ldx     #<_exit
        lda     #>_exit
        jsr     reset           ; Setup RESET vector

        ; Call the module constructors.
        jsr     initlib

        ; Set the source start address.
        ; Aka __LC_LOAD__ iff segment LC exists.
        lda     #<(__ONCE_LOAD__ + __ONCE_SIZE__)
        ldy     #>(__ONCE_LOAD__ + __ONCE_SIZE__)
        sta     $9B
        sty     $9C

        ; Set the source last address.
        ; Aka __LC_LOAD__ + __LC_SIZE__ iff segment LC exists.
        lda     #<(__ONCE_LOAD__ + __ONCE_SIZE__)
        ldy     #>(__ONCE_LOAD__ + __ONCE_SIZE__)
        sta     $96
        sty     $97

        rts

; ------------------------------------------------------------------------

        .code

        ; Set up the RESET vector.
reset:  stx     SOFTEV
        sta     SOFTEV+1
        eor     #$A5
        sta     PWREDUP
return: rts

        .data

; ------------------------------------------------------------------------

        .segment        "INIT"

zpsave: .res    zpspace
rvsave: .res    3
