sample_data	DCD		4,93,34,73,52,95,21,1,36,18,48,46,72,83,60,62,92,17,82,89,64,56,5,78,37,94,44,99,54,28,68,88,74,71,100,91,66,90,29,59
ss_result		DCD		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
bs_result		DCD		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
array_size	DCD		40
num_s		DCD		0
num_b		DCD		0
			
main
			
			bl		selection_sort
			bl		bubble_sort
			bl		exit
			
selection_sort
			mov		r10, #0			; r10 to count the num of instructions of selection sort
			mov		r12, #0			; r12 to count the num of instructions of buble sort
			mov		r4, #0
			add		r10, r10, #1
			adr		r5, sample_data	; reset registers before copy the array
			add		r10, r10, #1
			adr		r6, ss_result
			add		r10, r10, #1
			adr		r7, bs_result
do_copy
			
			ldr		r2, [r5], #4
			add		r10, r10, #1
			str		r2, [r6], #4
			add		r10, r10, #1
			str		r2, [r7], #4
			add		r12, r12, #1
			add		r4, r4, #1
			add		r10, r10, #1
			
			cmp		r4, #40
			add		r10, r10, #1
			add		r12, r12, #1
			blne		do_copy
			add		r10, r10, #1
			add		r12, r12, #1
			;-------------------------------------------------------------------
			adr		r0, ss_result
			add		r10, r10, #1
			ldr		r1, =array_size
			add		r10, r10, #1
			ldr		r9, [r1]		; r2 = n
			add		r10, r10, #1
			mov		r1, #0
			add		r10, r10, #1
			mov		r3, r1		; r1=r3=0
			add		r10, r10, #1
			sub		r7,r9,#1		; r7 = n-1
			add		r10, r10, #1
			add		r10, r10, #1
			bl		Outer_Loop
			
Outer_Loop
			mov		r4,r3
			add		r10, r10, #1
			add		r5,r3,#1
			add		r10, r10, #1
Inner_Loop							;r1 vs r2
			ldr		r1,[r0,r4,lsl #2]
			add		r10, r10, #1
			ldr		r2,[r0,r5,lsl #2]
			add		r10, r10, #1
			cmp		r2,r1
			add		r10, r10, #1
			movlt	r4,r5
			
			add		r10, r10, #1
			add		r5,r5,#1
			add		r10, r10, #1
			cmp		r5,r9
			add		r10, r10, #1
			add		r10, r10, #1
			blt		Inner_Loop
			add		r10, r10, #1
			cmp		r4,r3
			add		r10, r10, #1
			add		r10, r10, #1
			beq		AfterSwap  ; no need to Swap
			add		r10, r10, #1
			ldr		r1,[r0,r4,lsl #2]   ; do Swap
			add		r10, r10, #1
			ldr		r2,[r0,r3,lsl #2]
			add		r10, r10, #1
			str		r1,[r0,r3,lsl #2]
			add		r10, r10, #1
			str		r2,[r0,r4,lsl #2]
			add		r10, r10, #1
AfterSwap
			add		r3,r3,#1	; pivot index increment
			add		r10, r10, #1
			cmp		r3,r7     ; is the pivot at the end?
			add		r10, r10, #1
			add		r10, r10, #1
			blt		Outer_Loop
			ldr		r0, =num_s
			str		r10,[r0]
			;----------------------------------------------------------
			
bubble_sort
			ldr		r0, =array_size
			add		r12, r12, #1
			adr		r1, bs_result
			add		r12, r12, #1
			ldr		r0,[r0]
			add		r12, r12, #1
			sub		r0,r0,#1
			add		r12, r12, #1
New_Loop
			mov		r5,r0	; r5 = n-i
			add		r12, r12, #1
			mov		r10,r1	; r10 = offset+0,4,..
			add		r12, r12, #1
			
Compare
			ldr		r2,[r10]
			add		r12, r12, #1
			add		r11,r10,#4	; left=r10, right=r11
			add		r12, r12, #1
			ldr		r3,[r11]
			add		r12, r12, #1
			cmp		r2,r3
			add		r12, r12, #1
			ble		Skip
			
			str		r2,[r11]	; swap left and right
			add		r12, r12, #1
			str		r3,[r10]
			add		r12, r12, #1
Skip
			sub		r5,r5,#1
			add		r12, r12, #1
			add		r10,r10,#4
			add		r12, r12, #1
			cmp		r5,#0
			add		r12, r12, #1
			bne		Compare
			add		r12, r12, #1
			sub		r0,r0,#1
			add		r12, r12, #1
			cmp		r0,#0
			add		r12, r12, #1
			bne		New_Loop
			add		r12, r12, #1
			ldr		r0, =num_b
			str		r12,[r0]
			
exit
			
