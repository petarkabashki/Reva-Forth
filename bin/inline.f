| utility which dumps assembly-language as ready-to-paste "inline{" words
needs asm
forth
: cr? 0; 16 mod 0if cr 9 emit then ;
: hexbytes 0do count .2x  space i cr?  loop drop ;
macro
::
	cr ." : "
	last@ >name count type_
	." inline{ "
	lastxt here over - hexbytes
	." } ; " cr
	; alias ;
forth

: 1+ asm{ inc eax } ;
: 1- asm{ dec eax } ;
: 0; asm{ 
	or eax, eax
	jnz .done
	lodsd
	ret
	.done:
	} ;
: /char 
	asm{
	mov ebx, eax
	mov eax, [esi]
	lea esi, [esi+4]
	mov ecx, eax
	jecxz .bad
	mov edi, [esi] ; ptr
.next:	
    cmp byte [edi], bl	; matches?
	je .match
	inc edi
	loop .next
.match: 
    ; edi -> matching character
	cmp byte [edi], bl
	jne .bad
	jecxz .bad
	mov eax, ecx
	mov [esi], edi
	ret
.bad:	
    xor eax, eax
	mov [esi], eax
	} ;

: \char asm{
	mov ebx, eax
	mov eax, [esi]
	lea esi, [esi+4]
	mov ecx, eax
	jecxz .bad
	mov edi, [esi] ; ptr
	add edi, ecx
	dec edi	; edi-> last character
.next:	cmp byte [edi], bl	; matches?
	je .match
	dec edi
	loop .next
	jecxz .bad
.match: ; edi -> matching character
	cmp byte [edi], bl
	jne .bad 
	sub eax, ecx
	inc eax
	mov [esi], edi
	ret
.bad:	xor eax, eax
	mov [esi], eax
	} ;
: cmove> asm{
	; upop ecx
	mov ecx, eax	; N
	mov eax, [esi]
	lea esi, [esi+4]
	; upop edi
	mov edi, eax	; dest
	mov eax, [esi]
	lea esi, [esi+4]
	; upop edx
	mov edx, eax	; src
	mov eax, [esi]
	lea esi, [esi+4]
	jecxz .c

.a:	; overlap case
	add edx, ecx
	add edi, ecx
	align 4
.b:
	dec edx
	dec edi

	mov bl, byte [edx] 
	nop
	mov byte [edi], bl

	loop .b
.c:
	} ;
| Look for a2 in a1; a3 is returned if flag is true
| Case-sensitive; Uses BRUTEFORCE algorithm
| ( a1 n1 a2 n2 -- a3 n3 1 | 0 )	
: search asm{
;	upop edx	; n2
	mov edx, eax
	mov eax, [esi]
	lea esi, [esi+4]

;	upop edi	; a2
	mov edi, eax
	mov eax, [esi]
	lea esi, [esi+4]

;	upop ecx	; n2
	mov ecx, eax
	mov eax, [esi]
	lea esi, [esi+4]

	; EAX:ECX ==> A1
	; EDI:EDX ==> A2
	; be unamused by zero-length or NULL strings:
	push eax
	push ecx
	jecxz .failed
	or eax, eax
	jz .failed
	or edx, edx
	jz .failed
	or edi, edi
	jz .failed

	; main loop: scan for possible match: first character matches:
	; EAX:ECX --> string to search in; we bump through it until we fall off
	; the end:
.next:
	mov bh, byte [edi]	; first character of target - this won't change
.findstart:
	mov bl, byte [eax]	; get first character of source string
	cmp bl, bh
	je .maybe		; maybe we match; check it out
.nomatch:	; nah, bump to next char
	inc eax
	loop .findstart
	; if we made it here, we are big failures:
.failed:
	xor eax, eax
	pop ecx		; drop n2
	pop ecx		; drop a2
	ret

.maybe: ; EAX:ECX might be a match to EDI:EDX
	cmp ecx, edx
	jb .failed	; string-to-match is longer than matchee
	mov ebp, edx	; save matcher length
	dec ebp
.maybe2:
	mov bh, [edi+ebp]
	cmp bh, [eax+ebp]
	jne .nomatch2
	dec ebp
	jns .maybe2
	; fell off loop: we matched!
	;dup
	lea esi, [esi-4]
	mov [esi],eax

	pop eax		; N1
	sub eax, [esi]	; A1
	pop ebx
	add eax, ebx
	; upsh edx
	
	; dup
	lea esi, [esi-4]
	mov [esi],eax

.success:
	mov eax, -1
	ret
.nomatch2:
	inc eax
	jmp .next
	} ;
: do asm{
	mov ebx, eax
	lodsd
	push eax
	sub eax, ebx
	push eax
	lodsd
	} ;
: swap asm{
	mov ebx, eax
	mov eax, [esi]
	mov [esi], ebx
	} ;

: exec
	asm{
		lea ebx, [eax-4]
		mov ebx, [ebx]
		mov eax, [eax+4]
		jmp ebx
	}
	;
: outd ( value port -- ) asm{
	mov edx, eax
	lodsd
	out dx, eax
	lodsd
	} 
	;
: outw ( value port -- ) asm{
	mov edx, eax
	lodsd
	out dx, ax
	lodsd
	} 
	;
: outb ( value port -- ) asm{
	mov edx, eax
	lodsd
	out dx, al
	lodsd
	} 
	;

: ind ( port -- value ) asm{
	mov edx, eax
	in eax, dx
	} ;
: inw ( port -- value ) asm{
	mov edx, eax
	in ax, dx
	} ;
: inb ( port -- value ) asm{
	mov edx, eax
	in al, dx
	} ;
: xchg2 ( a1 a2 -- )
  asm{
    mov ebx, eax
    lodsd
    mov ecx, [ebx]
    mov edx, [eax]
    mov [ebx], edx
    mov [eax], ecx
    lodsd
  } ;
: -rot asm{
	push eax
	mov ebx, [esi+4]
	mov eax, [esi]
	mov [esi], ebx
	pop dword [esi+4]
	} ;
: rot asm{
	push eax
	mov eax, [esi+4]
	mov ebx, [esi]
	mov [esi+4], ebx
	pop dword [esi]
	} ;
: xchg asm{
	mov ebx, eax
	mov eax, [esi]
	lea esi, [esi+4]
	push eax
	mov eax, [ebx]
	pop dword [ebx]
	} ;
: d2/ asm{
	sar eax, 1
	sar dword [esi], 1
	} ;
: d2* asm{
	shl dword [esi], 1
	rcl eax,1
	} ;
: jmpto ( esi eax eip -- )
	asm{
		mov ebx, eax
		lodsd
		push eax
		lodsd
		mov esi, eax
		pop eax
		jmp ebx
	} ;
: 0_ asm{
	xor eax, eax
	} ;
: 0__ asm{
	mov dword [esi], 0
	} ;
: 00 asm{
	xor ebx, ebx
	mov [esi], ebx
};
: rot6 asm{
	mov ecx, eax
	mov eax, [esi+4]
	mov ebx, [esi]
	mov [esi+4], ebx
	mov [esi], ecx
} ;
| 1 2 3	- ecx=1
| 3 2 3 = ecx=1
| 3 2 1
: -rot6 asm{
	mov ecx, [esi+4]
	mov [esi+4], eax
	mov ebx, [esi]
	mov [esi], ecx
	mov eax, ebx
} ;

: -swap asm{
	mov ebx,[esi+04]
	mov ecx,[esi]
	mov [esi],ebx
	mov [esi+04], ecx
} ;

: over2 | 2 pick
	dup
	asm{
	mov eax, [esi+8]
	} ;
: over3 | 3 pick
	dup
	asm{
	mov eax, [esi+12]
	} ;
: fover asm{
	fld st1
	} ;
: xchgc ( a1 a2 -- )
  asm{
    mov ebx, eax
    lodsd
    mov cl, [ebx]
    mov dl, [eax]
    mov [ebx], dl
    mov [eax], cl
    lodsd
  } ;
 
: _1- asm{
	dec dword [esi]
	} ;
: _1+ asm{
	inc dword [esi]
	} ;

: _+ asm{
	add dword [esi+4], eax
	lodsd
} ;
