; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

INICIA_CIFRA:
			push	MSG_TAM					; Coloca no topo da pilha o valor de MSG_TAM
			mov		#MSG_CLARA,R5			; Coloca em R5 o endereço do primeiro elemento de MSG_CLARA
			mov		#MSG_CIFR,R6			; Coloca em R6 o endereço do primeiro elemento de MSG_CIFR
			jmp		INICIA_ROTORES			; Vai para a label INICIA_ROTORES
			nop

CONTINUA_CIFRA:
			call	#ENIGMA					; Chama a subrotina ENIGMA para cifrar a mensagem em claro

INICIA_DECIFRA:
			pop		MSG_TAM					; Coloca em MSG_TAM o valor do topo da pilha
			mov		#MSG_CIFR,R5			; Coloca em R4 o endereço do primeiro elemento de MSG_CIFR
			mov		#MSG_DECIFR,R6			; Coloca em R5 o endereço do primeiro elemento de MSG_DECIFR
			jmp		REINICIA_ROTOR1
			nop

CONTINUA_DECIFRA:
			call	#ENIGMA					; Chama a subrotina ENIGMA para decifrar e mensagem cifrada
			jmp		$						; Trava a execução do código
			nop								; Nenhum comando

INICIA_ROTORES:
			mov		#CHAVE,R4				; Coloca em R4 o endereço do primeiro elemento da CHAVE
			mov		@R4+,R8					; Coloca o valor de (R4) (Rotor da Esquerda) em R8 e incrementa R4
			mov		@R4+,R9					; Coloca o valor de (R4) (Config. Rotor Esquerda) em R9 e incrementa R4
			mov		@R4+,R10				; Coloca o valor de (R4) (Rotor Central) em R10 e incrementa R4
			mov		@R4+,R11				; Coloca o valor de (R4) (Config. Rotor Central) em R11 e incrementa R4
			mov		@R4+,R12				; Coloca o valor de (R4) (Rotor da Direita) em R12 e incrementa R4
			mov		@R4+,R13				; Coloca o valor de (R4) (Config. Rotor Direita) em R13 e incrementa R4
			mov		@R4,R14					; Coloca o valor de (R4) (Refletor) em R14
			clr		R15						; Zera o valor de R15
			dec		R8						; Decrementa o valor de R8
			jnz		ROTOR1					; Se diferente de zero, vai para a label ROTOR1

CONTINUA1:
			add		R15,R8					; Soma a R8 a quantidade de elementos que devem ser pulados a partir do primeiro índice de RT1
			clr		R15						; Zera o valor de R15
			dec		R10						; Decrementa o valor de R10
			jnz		ROTOR2					; Se diferente de zero, vai para a label ROTOR2

CONTINUA2:
			add		R15,R10					; Soma a R10 a quantidade de elementos que devem ser pulados a partir do primeiro índice de RT1
			clr		R15						; Zera o valor de R15
			dec		R12						; Decrementa o valor de R12
			jnz		ROTOR3					; Se diferente de zero, vai para a label ROTOR3

CONTINUA3:
			add		R15,R12					; Soma a R12 a quantidade de elementos que devem ser pulados a partir do primeiro índice de RT1
			mov		#RT1,R15				; Coloca o índice do primeiro elemento de RT1 em R15
			add		R15,R8					; Coloca em R8 o índice inicial do rotor da esquerda escolhido
			add		R15,R10					; Coloca em R10 o índice inicial do rotor central escolhido
			add		R15,R12					; Coloca em R12 o índice inicial do rotor da direita escolhido
			clr		R15						; Zera o valor de R15
			dec		R14						; Decrementa o valor de R14
			jz		TRAMA1					; Se igual a zero, o refletor escolhido foi o primeiro, portanto já se inicia a trama inicial dos rotores

REFLETOR:
			add		#26,R15					; Soma 26 a R15
			dec		R14						; Decrementa o valor de R14
			jnz		REFLETOR				; Se diferente de zero, retorna para a label REFLETOR
			add		R15,R14					; Coloca em R14 a quantidade de elementos que devem ser pulados a partir do primeiro índice de RF1
			mov		#RF1,R15				; Coloca o índice do primeiro elemento de RF1 em R15
			add		R15,R14					; Coloca em R14 o índice inicial do refletor escolhido
			clr		R15						; Zera o valor de R15

TRAMA1:
			mov.b	@R8,R15					; Coloca o valor do primeiro elemento do rotor da esquerda em R15
			push	AUX						; Coloca o valor de AUX no topo da pilha
			push	R8						; Coloca o valor de R8 no topo da pilha

SUB_TRAMA1:
			mov.b	1(R8),0(R8)				; Coloca o valor de (R8 + 1) em (R8 + 0)
			inc		R8						; Incrementa o valor de R8
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_TRAMA1				; Se diferente de zero, volta para a label SUB_TRAMA1
			pop		R8						; Coloca em R8 o valor do topo da pilha
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			mov.b	R15,25(R8)				; Coloca o valor de R15 na última posição do rotor da esquerda
			dec		R9						; Decrementa o valor de R9, ou seja, foi completada uma rotação para a esquerda
			jnz		TRAMA1					; Se diferente de zero, volta para a label TRAMA1

TRAMA2:
			mov.b	@R10,R15				; Coloca o valor do primeiro elemento do rotor central em R15
			push	AUX						; Coloca o valor de AUX no topo da pilha
			push	R10						; Coloca o valor de R8 no topo da pilha

SUB_TRAMA2:
			mov.b	1(R10),0(R10)			; Coloca o valor de (R10 + 1) em (R10 + 0)
			inc		R10						; Incrementa o valor de R10
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_TRAMA2				; Se diferente de zero, volta para a label SUB_TRAMA2
			pop		R10						; Coloca em R10 o valor do topo da pilha
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			mov.b	R15,25(R10)				; Coloca o valor de R15 na última posição do rotor central
			dec		R11						; Decrementa o valor de R11, ou seja, foi completada uma rotação para a esquerda
			jnz		TRAMA2					; Se diferente de zero, vai para a label TRAMA2

TRAMA3:
			mov.b	@R12,R15				; Coloca o valor do primeiro elemento do rotor da direita em R15
			push	AUX						; Coloca o valor de AUX no topo da pilha
			push	R12						; Coloca o valor de R12 no topo da pilha

SUB_TRAMA3:
			mov.b	1(R12),0(R12)			; Coloca o valor de (R12 + 1) em (R12 + 0)
			inc		R12						; Incrementa o valor de R12
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_TRAMA3				; Se diferente de zero, vai para a label SUB_TRAMA2
			pop		R12						; Coloca em R12 o valor do topo da pilha
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			mov.b	R15,25(R12)				; Coloca o valor de R15 na última posição do rotor da direita
			dec		R13						; Decrementa o valor de R13, ou seja, foi completada uma rotação para a esquerda
			jnz		TRAMA3					; Se diferente de zero, vai para a label TRAMA3
			jmp		CONTINUA_CIFRA			; Com todos os rotores e o refletor configurados, vai para a label CONTINUA_CIFRA
			nop								; Nenhuma instrução

ROTOR1:
			add		#26,R15					; Soma 26 ao valor de R15
			dec		R8						; Decrementa o valor de R8
			jnz		ROTOR1					; Se diferente de zero, volta para a subrotina ROTOR1
			jmp		CONTINUA1				; Vai para a label CONTINUA1
			nop								; Nenhuma instrução

ROTOR2:
			add		#26,R15					; Soma 26 ao valor de R15
			dec		R10						; Decrementa o valor de R10
			jnz		ROTOR2					; Se diferente de zero, volta para a subrotina ROTOR2
			jmp		CONTINUA2				; Vai para a label CONTINUA2
			nop								; Nenhuma instrução

ROTOR3:
			add		#26,R15					; Soma 26 ao valor de R15
			dec		R12						; Decrementa o valor de R12
			jnz		ROTOR3					; Se diferente de zero, volta para a subrotina ROTOR3
			jmp		CONTINUA3				; Vai para a label CONTINUA3
			nop								; Nenhuma instrução

REINICIA_ROTOR1:
			cmp.b	#0x0,A1					; Compara o número 0 com o valor de A1
			jeq		REINICIA_ROTOR2			; Se iguais, vai para a label REINICIA_ROTOR2

SALVA_VALOR1:
			mov.b	@R8,R15					; Coloca o valor do primeiro índice do rotor da esquerda em R15
			push	R8						; Coloca o valor de R8 no topo da pilha
			push	AUX						; Coloca o valor de AUX no topo da pilha

SUB_REINICIA_ROTOR1:
			mov.b	1(R8),0(R8)				; Coloca o valor de (R8 + 1) em (R8 + 0)
			inc		R8						; Incrementa o valor de R8
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_REINICIA_ROTOR1		; Se diferente de zero, volta para a label SUB_REINICIA_ROTOR1
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			pop		R8						; Coloca em R8 o valor do topo da pilha
			mov.b	R15,25(R8)				; Coloca na última posição do rotor da esquerda o valor de R15
			dec		A1						; Decrementa o valor de A1
			jnz		SALVA_VALOR1			; Se diferente de zero, volta para a label SALVA_VALOR1

REINICIA_ROTOR2:
			cmp.b	#0x0,A2					; Compara o número 0 com o valor de A2
			jeq		REINICIA_ROTOR3			; Se iguais, vai para a label REINICIA_ROTOR3

SALVA_VALOR2:
			mov.b	@R10,R15				; Coloca o valor do primeiro índice do rotor central em R15
			push	R10						; Coloca o valor de R10 no topo da pilha
			push	AUX						; Coloca o valor de AUX no topo da pilha

SUB_REINICIA_ROTOR2:
			mov.b	1(R10),0(R10)			; Coloca o valor de (R10 + 1) em (R10 + 0)
			inc		R10						; Incrementa o valor de R10
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_REINICIA_ROTOR2		; Se diferente de zero, volta para a label SUB_REINICIA_ROTOR2
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			pop		R10						; Coloca em R10 o valor do topo da pilha
			mov.b	R15,25(R10)				; Coloca na última posição do rotor central o valor de R15
			dec		A2						; Decrementa o valor de A2
			jnz		SALVA_VALOR2			; Se diferente de zero, volta para a label SALVA_VALOR2

REINICIA_ROTOR3:
			cmp.b	#0x0,A3					; Compara o número 0 com o valor de A3
			jeq		CONTINUA_DECIFRA		; Se iguais, vai para a label CONTINUA_DECIFRA

SALVA_VALOR3:
			mov.b	@R12,R15				; Coloca o valor do primeiro índice do rotor da direita em R15
			push	R12						; Coloca o valor de R12 no topo da pilha
			push	AUX						; Coloca o valor de AUX no topo da pilha

SUB_REINICIA_ROTOR3:
			mov.b	1(R12),0(R12)			; Coloca o valor de (R12 + 1) em (R12 + 0)
			inc		R12						; Incrementa o valor de R12
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_REINICIA_ROTOR3		; Se diferente de zero, volta para a label SUB_REINICIA_ROTOR3
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			pop		R12						; Coloca em R12 o valor do topo da pilha
			mov.b	R15,25(R12)				; Coloca na última posição do rotor da direita o valor de R15
			dec		A3						; Decrementa o valor de A3
			jnz		SALVA_VALOR3			; Se diferente de zero, volta para a label SALVA_VALOR3
			jmp		CONTINUA_DECIFRA		; Vai para a label CONTINUA_DECIFRA
			nop								; Nenhuma instrução

ENIGMA:
			clr		R9						; Zera o valor de R9
			clr		R11						; Zera o valor de R11
			clr		R13						; Zera o valor de R13
			mov.b	@R5,R7					; Coloca em R7 o valor do caractere de (R5)
			cmp.b	#0x5C,R7				; Compara o valor de R7 com 0x5C ( \ )
			jeq		ESPECIAL				; Se R7 == 0x5C, vai para a label ESPECIAL
			cmp.b	#0x41,R7				; Compara o valor de R7 com 0x41 ( A )
			jhs		CODIFICA				; Se R6 >= 0x41, vai para a label CODIFICA
			jlo		ESPECIAL				; Se R6 < 0x41, vai para a label ESPECIAL

CODIFICA:
			mov.b	@R5,R15					; Coloca em R15 o valor do caractere de (R5)
			sub.b	#0x41,R15				; Determina a distância do caractere R15 para a letra A
			add		R8,R15					; Soma o índice de memória R8 ao valor da diferença calculada acima
			mov.b	@R15,R15				; Coloca em R15 o valor presente no índice da memória do valor calculado acima (rotor 1)
			add		R10,R15					; Soma o índice de memória R10 ao valor retornado do rotor 1
			mov.b	@R15,R15				; Coloca em R15 o valor presente no índice da memória do valor calculado acima (rotor 2)
			add		R12,R15					; Soma o índice de memória R12 ao valor retornado do rotor 2
			mov.b	@R15,R15				; Coloca em R15 o valor presente no índice da memória do valor calculado acima (rotor 3)
			add		R14,R15					; Soma o índice de memória R12 ao valor retornado do rotor 3
			mov.b	@R15,R15				; Coloca em R15 o valor presente no índice da memória do valor calculado acima (refletor)
			push	R12						; Coloca o valor do índice do primeiro elemento do rotor da direita no topo da pilha

PROCURA_ROT3:
			cmp.b	R15,0(R12)				; Compara o valor selecionado do refletor com o elemento (R12 + 0) do rotor da direita
			jeq		ENCONTRA_ROT3			; Se iguais, vai para a label ENCONTRA_ROT3
			inc		R12						; Incrementa o valor de R12
			jmp		PROCURA_ROT3			; Retorna para a label PROCURA_ROT3
			nop								; Nenhuma instrução

ENCONTRA_ROT3:
			pop		R4						; Coloca em R4 o valor do topo da pilha
			sub		R4,R12					; Determina a distância entre o índice do elemento encontrado e o primeiro elemento do rotor da direita
			mov		R12,R15					; Coloca o valor calculado acima em R15
			mov		R4,R12					; Coloca o valor do índice inicial do rotor da direita em R12
			push	R10						; Coloca no topo da pilha o valor do primeiro índice do rotor central

PROCURA_ROT2:
			cmp.b	R15,0(R10)				; Compara o valor selecionado do rotor da direita com o elemento (R10 + 0) do rotor central
			jeq		ENCONTRA_ROT2			; Se iguais, vai para a label ENCONTRA_ROT2
			inc		R10						; Incrementa o valor de R10
			jmp		PROCURA_ROT2			; Retorna para a label PROCURA_ROT2
			nop								; Nenhuma instrução

ENCONTRA_ROT2:
			pop		R4						; Coloca em R4 o valor do topo da pilha
			sub		R4,R10					; Determina a distância entre o índice do elemento encontrado e o primeiro elemento do rotor central
			mov		R10,R15					; Coloca o valor calculado acima em R15
			mov		R4,R10					; Coloca o valor do índice inicial do rotor central em R12
			push	R8						; Coloca no topo da pilha o valor do primeiro índice do rotor da esquerda

PROCURA_ROT1:
			cmp.b	R15,0(R8)				; Compara o valor selecionado do rotor central com o elemento (R8 + 0) do rotor da esquerda
			jeq		ENCONTRA_ROT1			; Se iguais, vai para a label ENCONTRA_ROT1
			inc		R8						; Incrementa o valor de R8
			jmp		PROCURA_ROT1			; Retorna para a label PROCURA_ROT1
			nop								; Nenhuma instrução

ENCONTRA_ROT1:
			pop		R4						; Coloca em R4 o valor do topo da pilha
			sub		R4,R8					; Determina a distância entre o índice do elemento encontrado e o primeiro elemento do rotor da esquerda
			mov		R8,R15					; Coloca o valor calculado acima em R15
			mov		R4,R8					; Coloca o valor do índice inicial do rotor da esquerda em R8
			add.b	#0x41,R15				; Soma o valor de R15 à letra A
			mov.b	R15,0(R6)				; Coloca no índice (R6 + 0) da memória	a letra resultante da operação acima

ROTACIONA_ROTOR1:
			mov.b	25(R8),R15				; Coloca o valor do último elemento do rotor da esquerda em R15
			push	AUX						; Coloca o valor de AUX no topo da pilha
			push	R8						; Coloca o valor de R8 no topo da pilha
			add		#24,R8					; Soma a quantidade de vezes que o loop deve ocorrer ao valor do índice inicial do rotor da esquerda

SUB_ROTACIONA_ROTOR1:
			mov.b	0(R8),1(R8)				; Coloca o valor do elemento do índice (R8 + 0) em (R8 + 1)
			dec		R8						; Decrementa o valor de R8
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_ROTACIONA_ROTOR1	; Se diferente de zero, retorna para a label SUB_ROTACIONA_ROTOR1
			pop		R8						; Coloca em R8 o valor do topo da pilha
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			mov.b	R15,0(R8)				; Coloca no primeiro índice do rotor da esquerda o valor de R15
			inc		A1						; Incrementa o contador A1
			cmp.b	#0x1A,A1				; Compara o valor de A1 com o número 0x1A (26)
			jeq		ROTACIONA_ROTOR2		; Se forem iguais, vai para a label	ROTACIONA_ROTOR2
			jmp		FINAL					; Salta para a label FINAL
			nop								; Nenhuma instrução

ROTACIONA_ROTOR2:
			clr		A1						; Zera o valor de A1
			mov.b	25(R10),R15				; Coloca o valor do último elemento do rotor central em R15
			push	AUX						; Coloca o valor de AUX no topo da pilha
			push	R10						; Coloca o valor de R10 no topo da pilha
			add		#24,R10					; Soma a quantidade de vezes que o loop deve ocorrer ao valor do índice inicial do rotor central

SUB_ROTACIONA_ROTOR2:
			mov.b	0(R10),1(R10)			; Coloca o valor do elemento do índice (R10 + 0) em (R10 + 1)
			dec		R10						; Decrementa o valor de R10
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_ROTACIONA_ROTOR2	; Se diferente de zero, retorna para a label SUB_ROTACIONA_ROTOR2
			pop		R10						; Coloca em R10 o valor do topo da pilha
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			mov.b	R15,0(R10)				; Coloca no primeiro índice do rotor central o valor de R15
			inc		A2						; Incrementa o contador A2
			cmp.b	#0x1A,A2				; Compara o valor de A2 com o número 0x1A (26)
			jeq		ROTACIONA_ROTOR3		; Se forem iguais, vai para a label	ROTACIONA_ROTOR3
			jmp		FINAL					; Salta para a label FINAL
			nop								; Nenhuma instrução

ROTACIONA_ROTOR3:
			clr		A2						; Zera o valor de A2
			mov.b	25(R12),R15				; Coloca o valor do último elemento do rotor da direita em R15
			push	AUX						; Coloca o valor de AUX no topo da pilha
			push	R12						; Coloca o valor de R12 no topo da pilha
			add		#24,R12					; Soma a quantidade de vezes que o loop deve ocorrer ao valor do índice inicial do rotor da direita

SUB_ROTACIONA_ROTOR3:
			mov.b	0(R12),1(R12)			; Coloca o valor do elemento do índice (R12 + 0) em (R12 + 1)
			dec		R12						; Decrementa o valor de R12
			dec		AUX						; Decrementa o valor de AUX
			jnz		SUB_ROTACIONA_ROTOR3	; Se diferente de zero, retorna para a label SUB_ROTACIONA_ROTOR3
			pop		R12						; Coloca em R12 o valor do topo da pilha
			pop		AUX						; Coloca em AUX o valor do topo da pilha
			mov.b	R15,0(R12)				; Coloca no primeiro índice do rotor da direita o valor de R15
			inc		A3						; Incrementa o valor de A3
			cmp.b	#0x1A,A3				; Compara o valor de A3 com o número 0x1A (26)
			jeq		ZERA_A3					; Se forem iguais, vai para a label	ZERA_A3
			jmp		FINAL					; Salta para a label FINAL
			nop								; Nenhuma instrução

ZERA_A3:
			clr		A3						; Zera o valor de A3
			jmp		FINAL					; Salta para a label FINAL
			nop								; Nenhuma instrução

ESPECIAL:
			mov.b	R7,0(R6)				; Coloca na posição de memória (R6 + 0) o valor de R7, o caractere diferente de uma letra maiuscula
			jmp		FINAL					; Salta para a label FINAL
			nop								; Nenhuma instrução

FINAL:
			inc		R5						; Incrementa o valor de R5
			inc		R6						; Incrementa o valor de R6
			dec		MSG_TAM					; Decrementa o valor de MSG_TAM
			jnz		ENIGMA					; Se diferente de zero, retorna para a subrotina ENIGMA
			ret								; Retorna para o escopo INICIA_DECIFRA

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            .data							; Acesso à memória RAM;

;-------------------------------------------------------------------------------
; ***** Chave do problema *****
;-------------------------------------------------------------------------------
; Formato da chave:
;-------------------------------------------------------------------------------
; CHAVE:	A, B, C, D, E, F, G
; A = número do rotor à esquerda e B = sua configuração
; C = número do rotor central e D = sua configuração
; E = número do rotor à direita e F = sua configuração
; G = número do refletor
;-------------------------------------------------------------------------------

CHAVE:		.word	2, 4, 5, 8, 3, 3, 2

;-------------------------------------------------------------------------------
; ***** Área de dados do problema *****
;-------------------------------------------------------------------------------

RT_TAM:		.word	26						; Tamanho dos rotores
RT_QTD:		.word	05						; Quantidade de rotores
RF_QTD:		.word	03						; Quantidade de refletores

VAZIO:		.space	12						; Facilitador do endereço do rotor 1

ROTORES:

RT1:
			.byte	20, 6, 21, 25, 11, 15, 16, 18, 0, 7, 1, 22, 9
			.byte	17, 24, 5, 8, 23, 19, 13, 12, 14, 3, 2, 10, 4

RT2:
			.byte	12, 18, 25, 22, 2, 23, 9, 5, 3, 6, 15, 14, 24
			.byte	11, 19, 4, 8, 21, 17, 7, 16, 1, 0, 10, 13, 20

RT3:
			.byte	23, 21, 18, 2, 15, 14, 0, 25, 3, 8, 4, 17, 7
			.byte	24, 5, 10, 11, 20, 22, 1, 12, 9, 16, 6, 19, 13

RT4:
			.byte	22, 21, 7, 0, 16, 3, 4, 8, 2, 9, 23, 20, 1
			.byte	11, 25, 5, 24, 14, 12, 6, 18, 13, 10, 19, 17, 15

RT5:
			.byte	20, 17, 13, 11, 25, 16, 23, 3, 19, 4, 24, 5, 1
			.byte	12, 8, 9, 15, 22, 6, 0, 21, 7, 14, 18, 2, 10

REFLETORES:

RF1:
			.byte	14, 11, 25, 4, 3, 22, 20, 18, 15, 13, 12, 1, 10
			.byte	9, 0, 8, 24, 23, 7, 21, 6, 19, 5, 17, 16, 2

RF2:
			.byte	1, 0, 16, 25, 6, 24, 4, 23, 14, 13, 17, 18, 19
			.byte	9, 8, 22, 2, 10, 11, 12, 21, 20, 15, 7, 5, 3

RF3:
			.byte	21, 7, 5, 19, 18, 2, 16, 1, 14, 22, 24, 17, 20
			.byte	25, 8, 23, 6, 11, 4, 3, 12, 0, 9, 15, 10, 13

;-------------------------------------------------------------------------------
; ***** Área das mensagens em claro, cifrada e decifrada *****
;-------------------------------------------------------------------------------

MSG_CLARA:
			.byte	"UMA NOITE DESTAS, VINDO DA CIDADE PARA O ENGENHO NOVO,"
			.byte	" ENCONTREI NO TREM DA CENTRAL UM RAPAZ AQUI DO BAIRRO,"
			.byte	" QUE EU CONHECO DE VISTA E DE CHAPEU.@MACHADO\ASSIS",0

MSG_CIFR:
			.byte	"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			.byte	"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			.byte	"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0

MSG_DECIFR:
			.byte	"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
			.byte	"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
			.byte	"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",0

;-------------------------------------------------------------------------------
; ***** Variáveis do código *****
;-------------------------------------------------------------------------------

MSG_TAM:	.word	159						; Tamanho da mensagem
AUX:		.word	25						; Auxiliar para a trama dos rotores
A1:			.word	0						; Auxiliar para medir a quantidade de rotações do rotor 1
A2:			.word	0						; Auxiliar para medir a quantidade de rotações do rotor 2
A3:			.word	0						; Auxiliar para medir a quantidade de rotações do rotor 3

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
