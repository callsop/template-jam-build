;
; hello world / windows 64 bit
;
; craig allsop
;
section .text
default rel                             ; use relative addressing in 64bit

global  Start                           ; extern

Start:
        and     rsp, ~8                 ; align stack

        sub     rsp, 60h                ; reserve space (aligned)
        mov     rcx, gs:[60h]           ; _PEBx64 process environment block
        mov     rcx, [rcx+20h]          ; -> ProcessParameters
        mov     rcx, [rcx+28h]          ; -> StandardOutput handle
                                        ; 1 in: handle (rcx)
        xor     rdx, rdx                ; 2 in: event (rdx)
        xor     r8, r8                  ; 3 in: apc routine (r8)
        xor     r9, r9                  ; 4 in: apc context (r9)
        lea     rax, [rsp+8*9]          ; address of status block
        mov     [rsp+8*4], rax          ; 5 out: io status block
        lea     rax, [hello_msg]        ; address of message
        mov     [rsp+8*5], rax          ; 6 in: buffer
        mov     rax, hello_msg_len      ; length of message
        mov     [rsp+8*6], rax          ; 7 in: len
        mov     [rsp+8*7], rdx          ; 8 in: byte offset (0)
        mov     [rsp+8*8], rdx          ; 9 in: key (0)
        call    NtWriteFile

        mov     rcx, -1                 ; current process
        xor     rdx, rdx                ; return code
        call    NtTerminateProcess

        int     3                       ; never gets here

NtWriteFile:                            ; write to a handle
        mov     r10, rcx
        mov     eax, 8
        syscall
        ret

NtTerminateProcess:                     ; terminate process
        mov     r10, rcx
        mov     eax, 2ch
        syscall
        ret

section .data

hello_msg       db      'Hello World Asm', 13, 0
hello_msg_len   equ     $ - hello_msg

