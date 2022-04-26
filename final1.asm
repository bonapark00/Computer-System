INCLUDE C:\irvine\Irvine32.inc
INCLUDELIB C:\irvine\Irvine32.lib
INCLUDELIB C:\irvine\Kernel32.lib
INCLUDELIB c:\irvine\User32.lib

.data
	input_buffer						BYTE ?; one character from input file
;;;	output_buffer			BYTE 1000 DUP(?)		; 여기서 1000바꾸기
	
	nBufSize = 1								; 다시 생각
	
	nBytesCount		DWORD ?
	nBytesWrite		DWORD ?			; 뭘까?

	errorMsg				BYTE "Cannot Create a file", 0dh, 0ah, 0
	input_fileName	BYTE "input.txt", 0
	output_fileName	BYTE "output.txt", 0

	input_fileHandle	DWORD ?
	output_fileHandle DWORD ?

	operand				BYTE ?
	operand_stack		BYTE ?
	n_operand_stack	DWORD 0

	arr_postfix			BYTE ?
	n_arr_postfix		DWORD 0

	operator				BYTE ?
	operator1				BYTE ?
	operator2				BYTE ?

	operator_stack		BYTE ?
	n_operator_stack		DWORD 0

	result_num			DWORD	?
	result_length		DWORD ?
	result_string			BYTE 20 DUP(?)



.code
main PROC
	;---------------------------------------------------------------------------
	;---------------------------File Settings-------------------------------
	INVOKE CreateFile,
					ADDR input_fileName,
					GENERIC_READ,		; access mode
					DO_NOT_SHARE,
					NULL,
					OPEN_EXISTING,
					FILE_ATTRIBUTE_NORMAL,
					0
	mov input_fileHandle, eax			; save file handle
	.IF eax == INVALID_HANDLE_VALUE
		mov edx, OFFSET errorMsg
		call WriteString
		jmp Quit
	.ENDIF

	INVOKE WriteFile,
				ADDR output_fileName, 
				GENERIC_WRITE,
				DO_NOT_SHARE,
				NULL,
				CREATE_ALWAYS,
				FILE_ATTRIBUTE_NORMAL,
				0
	mov output_fileHandle, eax
	.IF eax == INVALID_HANDLE_VALUE
		mov edx, OFFSET errorMsg
		call WriteString
		jmp Quit
	.ENDIF
	;---------------------------------------------------------------------------
	;---------------------------------------Read text from an input file
	mov eax, 0

	INVOKE ReadFile,
		input_fileHandle,
		ADDR input_buffer,
		nBufSize,
		ADDR nBytesCount,
		0

	.WHILE nBytesCount != 0
		;-------------if input is LineBreaking Keywords----------------------------------------------------
		.IF(input_buffer == 0aH) || (input_buffer == 0dH)	;이거 바꿀 수 있나 생각
						; do noting	
		;--------------if input is INTEGER---------------------------------------------------------------------
		.ELSEIF(input_buffer>="0") && (input_buffer<="9")
						mov bl, input_buffer	
						;------------------------------ Read Next Characrer
						INVOKE ReadFile, 
									input_fileHandle,
									ADDR input_buffer,
									nBufSize,
									ADDR nBytesCount,
									0
						;-------------------------------If next Character is also an INTEGER
						.IF(input_buffer>="0") && (input_buffer<="9")
										mov al, input_buffer
										sub al, 48
										sub bl, 48
										mov operand, al
										mov al, bl
										mov dl, 10
										mul dl
										add operand, al
										; 숫자는 후위표기에 추가해주기 
										mov al, arr_postfix
										mov esi, n_arr_postfix
										mov [arr_postfix + esi], al
										inc n_arr_postfix
						;-----------------------If next Character is an Operator(+/-/*/=)
						.ELSE	
										sub bl, 48
										mov operand, bl
										; 숫자는 후위표기에 추가해주기 
										mov al, arr_postfix
										mov esi, n_arr_postfix
										mov [arr_postfix + esi], al
										inc n_arr_postfix

										; 받은 피연산자는 스택에 넣어주기
										mov al, input_buffer
										;이 사이에 어떤 연산 추가해주기!!
										mov operator, al

										;push an Operator to Operator Stack
										movzx eax, operator
										push eax
										inc n_operator_stack
						.ENDIF
		;--------------if input is Operator---------------------------------------------------------------------
		.ELSE
					mov al, input_buffer
					; 여기에 어떤 연산 추가해주기!
					move operator, al
					;push an Operator to Operator Stack
					movzx eax, operator
					push eax
					inc n_operator_stack
		.ENDIF
		;-----------------------------------------------------------------------------------------------------------
		; 연산자 스택에 연산자가 2개 이상 모여있다면
		; 상위 두연산자의 우선순위를 고려해본다.
		; 만약 최상위 연산자가 차상위 연산자보다 우선순위가 높다면 

		.IF(n_operator_stack >= 2)
					mov eax, n_operator_stack
					sub eax, 2
					mov n_operator_stack, eax
					pop operator1		; 최상위 operator
					pop operator2		; 차상위 operator

					; 최상위 연산자가 '='가 되어 식이 마무리된 경우
					; 스택에 남아있는 모든 연산자들을 팝하여 후위표기배열로 이동시킨다.
					.IF(operator1=="=")
							; 우선 차상위 연산자부터 후위표기배열로 이동시킨다
							mov esi, n_arr_postfix
							mov al, BYTE PTR operator2		; /// 이거 dl로 바꿔야 될 수 도 있다!!!
							mov [arr_postfix+esi], al
							inc n_arr_postfix

							; 스택이 모두 빌때까지 남은 연산자들을 팝한다
							.WHILE(n_operator_stack > 0)
									pop operator2
									mov esi, n_arr_postfix
									mov al, BYTE PTR operator2
									mov [arr_postfix+esi], al
									inc n_arr_postfix
									dec n_operator_stack
							.ENDW						

					; 최상위 연산자 우선순위 >= 차상위 연산자 우선순위
					; 그대로 두 연산자를 다시 스택에 푸쉬한다
					.ELSEIF((operator1=="*")&&((operator2=="+")||(operator2=="-")))
								push operator2
								push operator1
					; 최상위 연산자 우선순위 < 차상위 연산자 우선순위
					; 우선은 차상위 연산자를 후위표기배열로 이동시킨다
					; 그 다음 연산자들을 다시 최상위 연산자와 우선순위 비교를 하고,
					; 최상위 연산자보다 우선순위가 높다면, 계속 후위표기배열로 팝하여 이동시킨다.
					; 만약 최상위 연산자의 우선순위가 같거나 높은 연산자를 만나면,
					; 최상위 연산자를 스택에 푸쉬한다.
					.ELSE
								mov esi, n_arr_postfix
								mov al, BYTE PTR operator2
								mov [arr_postfix+esi], al
								inc n_arr_postfix

								.WHILE(n_operator_stack > 0)
										pop operator2
										dec n_operator_stack
										.IF((operator1=="*")&&((operator2=="+")||(operator2=="-")))
														push operator2
														inc n_operator_stack
														.BREAK
										.ENDIF
										mov esi, n_arr_postfix
										mov al, BYTE PTR operator2
										mov [arr_postfix+esi], al
										inc n_arr_postfix
								.ENDW
								push operator1
								inc n_operator_stack
					.ENDIF
			.ENDIF
			
			pop operator
			dec n_operator_stack
			
			; 
			.IF(operator!="=")
					push operator
					inc n_operator_stack
			.ELSE
					mov ecx, n_postfix
					mov esi, 0
					movzx eax, n_postfix[esi]
					mov n_operand_stack, 0

					Calculate: 
							; 후위표기에 있는 모든 요소들을 차례로 처리
							; 피연산자면 스택에 푸쉬하고
							; 연산자면 스택에서 두 피연산자를 팝한 후, 계산한다
							.IF eax==("+")
									pop edx
									dec n_operand_stack
									pop eax
									dec n_operand_stack
									add eax, edx
									push eax
									inc n_operand_stack
							.ELSEIF eax==("-")
									pop edx
									dec n_operand_stack
									pop eax
									dec n_operand_stack
									sub eax, edx
									push eax
									inc n_operand_stack
							.ELSEIF eax==("*")
									pop edx
									dec n_operand_stack
									pop eax
									dec n_operand_stack
									mul edx
									push eax
									inc n_operand_stack
							.ELSE	; 피연산자인 경우
									push eax
									inc n_operand_stack
							.ENDIF
							inc esi	; 포인터 +1
					loop Calculate

					pop eax	; 최종 결과를 eax에 담기
					mov result_num, eax

					; 다음 줄 입력 받rh&/현재 결과 출력 전에 레지스터/메모리 초기화
					mov eax, 0
					mov ecx, 0
					mov esi, 0
					mov edi, 0
					mov result_length, 0	
					mov n_operator_stack, 0
					mov n_operand_stack, 0
					mov n_arr_postfix, 0


					; 완전 걍 가정임!
					mov result_length, 3

					INVOKE ReadFile,
						input_fileHandle, ADDR input_buffer, nBufSize,	ADDR nBytesCount, 0

				INVOKE WRITEFILE,
						 output_fileHandle, ADDR result_num, result_length , ADDR bytesWritten,0

		.ENDW

		; Close all files
		INVOKE CloseHandle, input_fileHandle
		INVOKE CloseHandle, output_fileHandle



Quit:
	INVOKE ExitProcess, 0

main ENDP
end main