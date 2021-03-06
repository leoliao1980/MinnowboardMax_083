;------------------------------------------------------------------------------
;
; Copyright (c) 2007, Intel Corporation. All rights reserved.<BR>
; This program and the accompanying materials
; are licensed and made available under the terms and conditions of the BSD License
; which accompanies this distribution.  The full text of the license may be found at
; http://opensource.org/licenses/bsd-license.php
;
; THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
; WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
;
; Module Name:
;
;   SetMem.asm
;
; Abstract:
;
;   memset function
;
; Notes:
;
;------------------------------------------------------------------------------

    .code

;------------------------------------------------------------------------------
; VOID *
; memset (
;   OUT     VOID                      *Buffer,    --> rcx
;   IN      UINT8                     Value,      --> rdx
;   IN      UINTN                     Length      --> r8
;   );
;------------------------------------------------------------------------------
memset   PROC    USES    rdi
    mov     rax, rcx    
    cmp     r8, 0                       ; if Size == 0, do nothing
    je      @SetDone                    
    mov     rax, rdx                    ; rdx <-> r8
    mov     rdx, r8                     ; rdx <- Length
    mov     r8, rax                     ; r8  <- Value
    
    mov     rdi, rcx                    ; rdi <- Buffer
    mov     al, r8b                     ; al <- Value
    mov     r9, rdi                     ; r9 <- Buffer as return value
    xor     rcx, rcx
    sub     rcx, rdi
    and     rcx, 15                     ; rcx + rdi aligns on 16-byte boundary
    jz      @F
    cmp     rcx, rdx
    cmova   rcx, rdx
    sub     rdx, rcx
    rep     stosb
@@:
    mov     rcx, rdx
    and     rdx, 15
    shr     rcx, 4
    jz      @SetBytes
    mov     ah, al                      ; ax <- Value repeats twice
    movd    xmm0, eax                   ; xmm0[0..16] <- Value repeats twice
    pshuflw xmm0, xmm0, 0               ; xmm0[0..63] <- Value repeats 8 times
    movlhps xmm0, xmm0                  ; xmm0 <- Value repeats 16 times
@@:
    movdqa  [rdi], xmm0                 ; rdi should be 16-byte aligned
    add     rdi, 16
    loop    @B
@SetBytes:
    mov     ecx, edx                    ; high 32 bits of rcx are always zero
    rep     stosb
    mov     rax, r9                     ; rax <- Return value
@SetDone:
    ret
memset   ENDP

    END
