INCLUDE C:\irvine\Irvine32.inc
INCLUDELIB C:\irvine\Irvine32.lib
INCLUDELIB C:\irvine\Kernel32.lib
INCLUDELIB c:\irvine\User32.lib

.data
	input_buffer						BYTE ?; one character from input file
;;;	output_buffer			BYTE 1000 DUP(?)		; ���⼭ 1000�ٲٱ�
	
	nBufSize = 1								; �ٽ� ����
	
	nBytesCount		DWORD ?
	nBytesWrite		DWORD ?			; ����?

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
		.IF(input_buffer == 0aH) || (input_buffer == 0dH)	;�̰� �ٲ� �� �ֳ� ����
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
										; ���ڴ� ����ǥ�⿡ �߰����ֱ� 
										mov al, arr_postfix
										mov esi, n_arr_postfix
										mov [arr_postfix + esi], al
										inc n_arr_postfix
						;-----------------------If next Character is an Operator(+/-/*/=)
						.ELSE	
										sub bl, 48
										mov operand, bl
										; ���ڴ� ����ǥ�⿡ �߰����ֱ� 
										mov al, arr_postfix
										mov esi, n_arr_postfix
										mov [arr_postfix + esi], al
										inc n_arr_postfix

										; ���� �ǿ����ڴ� ���ÿ� �־��ֱ�
										mov al, input_buffer
										;�� ���̿� � ���� �߰����ֱ�!!
										mov operator, al

										;push an Operator to Operator Stack
										movzx eax, operator
										push eax
										inc n_operator_stack
						.ENDIF
		;--------------if input is Operator---------------------------------------------------------------------
		.ELSE
					mov al, input_buffer
					; ���⿡ � ���� �߰����ֱ�!
					move operator, al
					;push an Operator to Operator Stack
					movzx eax, operator
					push eax
					inc n_operator_stack
		.ENDIF
		;-----------------------------------------------------------------------------------------------------------
		; ������ ���ÿ� �����ڰ� 2�� �̻� ���ִٸ�
		; ���� �ο������� �켱������ ����غ���.
		; ���� �ֻ��� �����ڰ� ������ �����ں��� �켱������ ���ٸ� 

		.IF(n_operator_stack >= 2)
					mov eax, n_operator_stack
					sub eax, 2
					mov n_operator_stack, eax
					pop operator1		; �ֻ��� operator
					pop operator2		; ������ operator

					; �ֻ��� �����ڰ� '='�� �Ǿ� ���� �������� ���
					; ���ÿ� �����ִ� ��� �����ڵ��� ���Ͽ� ����ǥ��迭�� �̵���Ų��.
					.IF(operator1=="=")
							; �켱 ������ �����ں��� ����ǥ��迭�� �̵���Ų��
							mov esi, n_arr_postfix
							mov al, BYTE PTR operator2		; /// �̰� dl�� �ٲ�� �� �� �� �ִ�!!!
							mov [arr_postfix+esi], al
							inc n_arr_postfix

							; ������ ��� �������� ���� �����ڵ��� ���Ѵ�
							.WHILE(n_operator_stack > 0)
									pop operator2
									mov esi, n_arr_postfix
									mov al, BYTE PTR operator2
									mov [arr_postfix+esi], al
									inc n_arr_postfix
									dec n_operator_stack
							.ENDW						

					; �ֻ��� ������ �켱���� >= ������ ������ �켱����
					; �״�� �� �����ڸ� �ٽ� ���ÿ� Ǫ���Ѵ�
					.ELSEIF((operator1=="*")&&((operator2=="+")||(operator2=="-")))
								push operator2
								push operator1
					; �ֻ��� ������ �켱���� < ������ ������ �켱����
					; �켱�� ������ �����ڸ� ����ǥ��迭�� �̵���Ų��
					; �� ���� �����ڵ��� �ٽ� �ֻ��� �����ڿ� �켱���� �񱳸� �ϰ�,
					; �ֻ��� �����ں��� �켱������ ���ٸ�, ��� ����ǥ��迭�� ���Ͽ� �̵���Ų��.
					; ���� �ֻ��� �������� �켱������ ���ų� ���� �����ڸ� ������,
					; �ֻ��� �����ڸ� ���ÿ� Ǫ���Ѵ�.
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
							; ����ǥ�⿡ �ִ� ��� ��ҵ��� ���ʷ� ó��
							; �ǿ����ڸ� ���ÿ� Ǫ���ϰ�
							; �����ڸ� ���ÿ��� �� �ǿ����ڸ� ���� ��, ����Ѵ�
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
							.ELSE	; �ǿ������� ���
									push eax
									inc n_operand_stack
							.ENDIF
							inc esi	; ������ +1
					loop Calculate

					pop eax	; ���� ����� eax�� ���
					mov result_num, eax

					; ���� �� �Է� ��rh&/���� ��� ��� ���� ��������/�޸� �ʱ�ȭ
					mov eax, 0
					mov ecx, 0
					mov esi, 0
					mov edi, 0
					mov result_length, 0	
					mov n_operator_stack, 0
					mov n_operand_stack, 0
					mov n_arr_postfix, 0


					; ���� �� ������!
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