INCLUDE Irvine32.inc
INCLUDE Macros.inc

BUFFER_SIZE = 5000

.data
Key BYTE ?
fileName BYTE "Students Data.txt", 0
fileHandle HANDLE ?
newLine BYTE 0Dh, 0Ah
comma BYTE ','

studentID byte 5 dup(?), 0
szID byte ?
studentName byte 50 dup(?), 0
szName byte ?
grade byte 3 dup(?), 0
szGrade byte ?
secNumber byte ?, 0

buffer BYTE BUFFER_SIZE DUP(?)
szBuffer DWORD 0

tempBuffer BYTE BUFFER_SIZE DUP(?)
szTempBuffer DWORD 0
Rec BYTE 50 DUP(?)
szRec DWORD ?

studentCounter1 DWORD 0
studentCounter2 DWORD 0

intNum DWORD ?

maxStudentID byte 5 dup(?), 0
szMaxStudentID DWORD ?
maxStudentGrade DWORD ?

;=================================== Data : Update Studant  ===================================
Get_Student_Id BYTE "Please Enter Student Id To Update : ",0
Get_Student_Name BYTE "Please Enter Student Grade To Update : ",0
File_Is_Empty BYTE "Error : There is No student in This file ! ",0
Student_Not_Found BYTE "Error : There is no Student with this Id In This File ! ",0

Update_Buffer BYTE BUFFER_SIZE DUP(?),0
Size_Update_Buffer DWORD ?

Temp DWORD 0 

Row BYTE 50 DUP(?),0
Size_Row DWORD 0
Row_Offset DWORD 0

checked_Id BYTE 5 DUP(0),0
Size_checked_Id DWORD 0

Names BYTE 50 DUP (?) , 0
Size_Name DWORD 0 

Grades BYTE 50 DUP (0) , 0
Size_Grades DWORD 0 

SectiOn BYTE 50 DUP (?) , 0
size_SectiOn DWORD 0 

Target_Grade_Size DWORD 0 
Target_ID_Size DWORD 0 


Row_Is_Updated DWORD 0

ID_Counter DWORD 0 
Name_Counter DWORD 0 
Grade_Counter DWORD 0
Section_Counter DWORD 0

Temp2 DWORD 0 

TheIntNumber DWORD 0 
TheIntNumber2 BYTE 0 

;-----------------------------------
; Data : Read Row PROC
;-----------------------------------
Read_Row BYTE 50 DUP(?),0
Size_Read_Row DWORD 0
Read_Row_Offset DWORD 0

Cheak_Id BYTE 5 DUP(0),0
Size_Cheak_Id DWORD 0

;-----------------------------------
; Data : Delete Studant PROC
;-----------------------------------
Get_Studant_Id BYTE "Please Enter Studant Id to Delete : ",0
Empty_File BYTE "Error : There is no studant in file ! ",0
Studant_Not_Found BYTE "Error : There is no studant with this id in file ! ",0

New_Buffer BYTE BUFFER_SIZE DUP(?),0
Size_New_Buffer DWORD ?

Target_Int DWORD 0

Row_Is_Deleted DWORD 0

;-----------------------------------
; Data : Generate Section Report
;-----------------------------------

Sec_Genrated BYTE "Section Report Successfully Generated ...",0
Get_Sec_Number BYTE "Please Enter Number of Section To Generate Section Report : ",0
Empty_Sec BYTE "There Is No Student In this Section Please Try Again !",0

Sec1_File_Name BYTE "Section(1)_Report.txt", 0
Sec2_File_Name BYTE "Section(2)_Report.txt", 0

Read_Sec_Number BYTE ?

Student_Id BYTE 5 DUP(?),0
Size_Student_Id DWORD 0;

Student_Name BYTE 50 DUP(?)
Size_Student_Name DWORD 0

Student_Grade BYTE 3 DUP(?)
Size_Student_Grade DWORD 0

Student_Sec BYTE ?

New_Row BYTE 50 DUP(?),0

Sorted_Buffer BYTE BUFFER_SIZE DUP(?),0
Size_Sorted_Buffer DWORD ?

Temp_Buffer BYTE BUFFER_SIZE DUP(?),0
Size_Temp_Buffer DWORD ?

Index_Min_Id DWORD 0

Array_Students_Id DWORD 100 DUP(?)
Size_Array DWORD 0

Alpha_Grade BYTE ?

Loop_Counter DWORD 0
Counter DWORD 0

select byte ?

.code
DeleteStudent PROTO, Target_Id:PTR BYTE, Target_Size:DWORD
DisplayStudentData PROTO sID:DWORD
SaveDatabase PROTO, fileN:PTR BYTE
;---------------------------------------------------------
;Convert String to Intger number
;Receives: Pointer to String and Size of String
;Return: Intger Number in intNum variable
;---------------------------------------------------------
ConvertStringToInt PROC uses edx esi ebx ecx eax, stringPtr:PTR BYTE, stringSize: DWORD 
	mov intNum, 0
	
	mov edx, 0
	mov esi, 10
	mov ebx, stringPtr
	mov ecx, stringSize
	convert:
		push ecx
		movzx eax, byte ptr [ebx] 
		sub eax, '0'

		dec ecx
		cmp ecx, 0
		je lastNum

		power:
			mul esi
		loop power

		lastNum:
		add intNum, eax
		inc ebx
		pop ecx
	loop convert

	ret
ConvertStringToInt ENDP

;-----------------------------------------------------------------
; Read Row PROC
; Receives: Buffer Offset, Buffer Size
; Return : Row -> Read_Row, Row Size -> Size_Read_Row
;		   Buffer Offset -> Read_Row_Offset, Row Id -> Cheak_Id
;-----------------------------------------------------------------
Read_Row_Function PROC, Buffer_Offset:PTR BYTE
	    mov Size_Read_Row, 0
		mov Size_Cheak_Id, 0

		mov esi, Buffer_Offset
		mov ecx, 1
		mov ebx, Read_Row_Offset
		mov edx, 0
		Cheak_NewLine:
			mov al, [esi + ebx]
			cmp al, newLine
			je Row_Is_Read
			mov [Read_Row + edx], al
			add Size_Read_Row, 1
			add ebx, 1
			add edx, 1
			add ecx, 1
		loop Cheak_NewLine

		Row_Is_Read:

		mov eax, Size_Read_Row
		add eax, 2
		add Read_Row_Offset, eax

		mov ecx, Size_Read_Row
		mov ebx, 0
		mov edx, 0
		Read_Studant_Id:
			mov al, [Read_Row + ebx]
			cmp al, comma
			je Break
			mov [Cheak_Id + edx], al
			add Size_Cheak_Id, 1
			add edx, 1
			add ebx, 1
		loop Read_Studant_Id
		Break:
		ret
Read_Row_Function ENDP

;-----------------------------------------------------------------
; Bubble Sort PROC
; Receives : Offset Array DWORD, Array Size
; Return : No thing
;-----------------------------------------------------------------
BubbleSort PROC USES eax ecx esi, pArray:PTR DWORD, Count:DWORD 
	mov ecx,Count
	dec ecx 
	L1: 
		push ecx 
		mov esi,pArray 
	L2: 
		mov eax,[esi] 
		cmp [esi+4],eax 
		jg L3 ; if [ESI] <= [ESI+4]
		xchg eax,[esi+4] 
		mov [esi],eax
	L3: 
		add esi,4 
	loop L2 
		pop ecx 
	loop L1 
	L4: 
	
	ret
BubbleSort ENDP

;-----------------------------------------------------------------
; Get Alpha Grade PROC
; Receives : Offset of Int Grade, Size Grade
; Return : Alpha Grade -> Alpha_Grade
;-----------------------------------------------------------------
Get_Alpha_Grade PROC, Grade_Offset :PTR BYTE, Grade_Size: PTR DWORD
	
	mov ebx, Grade_Size
	Invoke ConvertStringToInt, Grade_Offset, ebx
	mov ebx, intNum

	cmp ebx, 60
	jae Else_If1

		mov Alpha_Grade, "F"
		ret

	Else_If1:
	cmp ebx, 70
	jae Else_If2

		mov Alpha_Grade, "D"
		ret

	Else_If2:
	cmp ebx, 80
	jae Else_If3

		mov Alpha_Grade, "C"
		ret

	Else_If3:
	cmp ebx, 90
	jae Else_If

		mov Alpha_Grade, "B"
		ret

	Else_If:
		
		mov Alpha_Grade, "A"
		ret

Get_Alpha_Grade ENDP

;-----------------------------------------------------------------
; Get Studant Info PROC
; Receives : Student Id : DWORD
; Return : Student_Id, Student_Name, Student_Grade, Studant_Sec
;-----------------------------------------------------------------
Get_Studant_Info PROC, Studant_Id:DWORD
	mov Read_Row_Offset, 0
	mov Size_Read_Row, 0
	mov Size_Cheak_Id, 0

	While_Loop:

	mov Size_Read_Row, 0
	mov Size_Cheak_Id, 0

	Invoke Read_Row_Function, offset buffer
	Invoke ConvertStringToInt, offset Cheak_Id, Size_Cheak_Id
	mov ebx, intNum

	cmp ebx, Studant_Id
	je Break

	jmp While_Loop

	Break:
		
		mov Size_Student_Id, 0
		mov Size_Student_Name, 0
		mov Size_Student_Grade, 0
		

		mov ecx, Size_Read_Row
		mov ebx, 0
		mov esi, 0
		Split_At_Comma:
			mov al, [Read_Row + ebx]
			cmp al, Comma
			je Comma_Found

			cmp esi, 0
			jne Studant_Name

			mov edi, Size_Student_Id
			mov [Student_Id + edi], al
			add Size_Student_Id, 1
			jmp Again

			Studant_Name:
			cmp esi, 1
			jne Studant_Grade
			
			mov edi, Size_Student_Name
			mov [Student_Name + edi], al
			add Size_Student_Name, 1
			jmp Again

			Studant_Grade:
			cmp esi, 2
			jne Studant_Sec
			
			mov edi, Size_Student_Grade
			mov [Student_Grade + edi], al
			add Size_Student_Grade, 1
			jmp Again

			Studant_Sec:
			
			mov edi, 0
			mov Student_Sec, al

			Comma_Found:
			add esi, 1

			Again:
			add ebx, 1
		loop Split_At_Comma

		Invoke Get_Alpha_Grade, offset Student_Grade, Size_Student_Grade

		mov ecx, Size_Student_Id
		mov edx, Size_Sorted_Buffer
		mov ebx, 0
		Copy_Id:
			mov al, [Student_Id + ebx]
			mov [Sorted_Buffer + edx], al
			add Size_Sorted_Buffer, 1
			add ebx, 1
			add edx, 1
		loop Copy_Id

		mov al, " "
		mov [Sorted_Buffer + edx], al
		add Size_Sorted_Buffer, 1

		mov ecx, Size_Student_Name
		mov edx, Size_Sorted_Buffer
		mov ebx, 0
		Copy_Name:
			mov al, [Student_Name + ebx]
			mov [Sorted_Buffer + edx], al
			add Size_Sorted_Buffer, 1
			add ebx, 1
			add edx, 1
		loop Copy_Name

		mov al, " "
		mov [Sorted_Buffer + edx], al
		add Size_Sorted_Buffer, 1

		mov ecx, Size_Student_Grade
		mov edx, Size_Sorted_Buffer
		mov ebx, 0
		Copy_Grade:
			mov al, [Student_Grade + ebx]
			mov [Sorted_Buffer + edx], al
			add Size_Sorted_Buffer, 1
			add ebx, 1
			add edx, 1
		loop Copy_Grade

		mov al, " "
		mov [Sorted_Buffer + edx], al
		add Size_Sorted_Buffer, 1


		add edx, 1
		mov al, Alpha_Grade
		mov [Sorted_Buffer + edx], al
		add Size_Sorted_Buffer, 1

		add edx, 1
		mov al, 0Dh
		mov [Sorted_Buffer + edx], al
		add Size_Sorted_Buffer, 1

		add edx, 1
		mov al, 0Ah
		mov [Sorted_Buffer + edx], al
		add Size_Sorted_Buffer, 1

		ret
Get_Studant_Info ENDP

;-----------------------------------------------------------------
; Generate Section Report PROC
; Receives : Offset Sction Number : BYTE
; Return : No thing
;-----------------------------------------------------------------
Generate_Section_Report PROC SecNum : BYTE
	mov eax, szBuffer
	cmp eax, 0
	jne Not_Empty

	mov edx, offset Empty_File
	call writestring
	ret

	Not_Empty:
	mov Size_Temp_Buffer,0

	mov ecx, szBuffer
	mov ebx, 0
	Copy_Buffer_Temp:
		mov al, [buffer + ebx]
		mov [Temp_Buffer + ebx], al
		add Size_Temp_Buffer, 1
		add ebx, 1
	loop Copy_Buffer_Temp

	mov szBuffer, 0

	mov Read_Row_Offset, 0
	
	While_Loop:
		mov eax, Size_Temp_Buffer
		cmp eax, Read_Row_Offset
		je Break

		mov Size_Read_Row, 0
		mov Size_Cheak_Id, 0

		Invoke Read_Row_Function, offset Temp_Buffer

		mov ebx, Size_Read_Row
		sub ebx, 1
		mov al, [Read_Row + ebx]

		cmp al, SecNum
		jne While_Loop

	    Invoke ConvertStringToInt, Offset Cheak_Id, Size_Cheak_Id
		mov edx, intNum
		mov ebx, Size_Array
		mov [Array_Students_Id + (ebx * 4)], edx
		add Size_Array, 1

		jmp While_Loop

		Break:

		mov eax, Size_Array
		cmp eax, 0
		jne Sec_Not_Empty

		call crlf
		mov edx, offset Empty_Sec
		call writestring
		call crlf
		jmp Out_Function

		Sec_Not_Empty:

		mov eax, Size_Array
		cmp eax, 1
		je Not_Need_Sort

		Invoke BubbleSort, offset Array_Students_Id, Size_Array

		Not_Need_Sort:

		mov ecx, Size_Array
		mov ebx, 0
		Copy_Sorted_Row:
			mov eax, [Array_Students_Id + ebx]
			mov Loop_Counter, ecx
			mov Counter, ebx
			Invoke Get_Studant_Info, eax
			mov ebx, Counter
			mov ecx, Loop_Counter
			add ebx, 4
		loop Copy_Sorted_Row
		
		mov szBuffer, 0
		mov ecx, Size_Sorted_Buffer
		mov ebx, 0
		Write_File_Sec:
			mov al, [Sorted_Buffer + ebx]
			mov [buffer + ebx], al
			add szBuffer, 1
			add ebx, 1
		loop Write_File_Sec

		mov al, SecNum
		cmp al, "2"
		je Section2
		INVOKE SaveDatabase, offset Sec1_File_Name
		jmp Print_String

		Section2:
		INVOKE SaveDatabase, offset Sec2_File_Name

		Print_String:
		call crlf
		mov edx, offset Sec_Genrated
		call writestring
		call crlf

		Out_Function:
		mov szBuffer, 0
		mov ecx, Size_Temp_Buffer
		mov ebx, 0
		Return_Old_Buffer:
			mov al, [Temp_Buffer + ebx]
			mov [buffer + ebx], al
			add szBuffer, 1
			add ebx,1
		loop Return_Old_Buffer
		ret
Generate_Section_Report ENDP

;-------------------------------------------------
;Display Top Student by ID
;Recieves: Student ID
;-------------------------------------------------
DisplayTopStudent PROC sID:DWORD
	mov esi, offset buffer
	mov ecx, szBuffer

	cmp ecx, 0
	je notFound

	checkAllRec:
		push ecx
		mov edi, offset Rec
		mov al, 0Dh
		mov ecx, 50
		getRec:
			cmp byte ptr [esi], al
			je RecReadDone
			mov bl, byte ptr [esi]
			mov byte ptr [edi], bl
			inc esi
			inc edi
		loop getRec

		RecReadDone:
		add esi, 2
		push esi
		sub ecx, 50
		neg ecx
		mov szRec, ecx

		;check is the same id or not
		mov esi, offset Rec
		mov al, comma
		mov ecx, szRec
		checkID:
			cmp byte ptr [esi], al
			je outCheckID
			inc esi
		loop checkID
		outCheckID:
		sub ecx, szRec
		neg ecx
		mov edx, ecx
		mov esi, offset rec
		invoke ConvertStringToInt,
			esi, edx
		mov eax, intNum
		cmp eax, sID
		jne notID
		mov ebx, 1
		jmp ID
		notID:
		mov ebx, 0
		ID:
		pop esi
		pop ecx
		sub ecx, szRec
		sub ecx, 2
		cmp ebx, 1
		je endCheckAllRec
		cmp ecx, 0
		je endCheckAllRec
	jmp checkAllRec
	endCheckAllRec:

	cmp ebx, 1
	jne notFound
	Found:
		mov esi, offset Rec
		mov edi, offset Rec
		mov ecx, szRec
		coutID:
			cmp byte ptr [edi], ','
			je outCoutID
			inc edi
		loop coutID
		outCoutID:
		mov byte ptr [edi], 0
		mov edx, esi
		call writestring
		mWrite <09h>
		inc edi
		mov esi, edi

		coutName:
			cmp byte ptr [edi], ','
			je outCoutName
			inc edi
		loop coutName
		outCoutName:
		mov byte ptr [edi], 0
		mov edx, esi
		call writestring
		mWrite <09h>
		inc edi
		mov esi, edi

		coutGrade:
			cmp byte ptr [edi], ','
			je outCoutGrade
			inc edi
		loop coutGrade
		outCoutGrade:
		mov byte ptr [edi], 0
		mov edx, esi
		call writestring
		mWrite <09h>

		mov eax, edi
		sub eax, esi
		invoke Get_Alpha_Grade,
			esi, eax
		mov al, Alpha_Grade
		call writechar
		call crlf
	ret

	notFound:
		mWrite <"Not Found ID", 0Dh, 0Ah>
	ret
DisplayTopStudent ENDP

;---------------------------------------------------------
;Display Top 5 Students
;---------------------------------------------------------
DisplayTop5 PROC
	cld
	cmp szBuffer, 0
	je return

	mov esi, offset buffer
	mov edi, offset tempBuffer
	mov ecx, szBuffer
	mov szTempBuffer, ecx
	rep movsb

	mov ecx, 5
	top5:
		push ecx
		mov maxStudentGrade, 0
		
		mov esi, offset buffer
		mov ecx, szBuffer
		checkAllRec:
			push ecx
			mov edi, offset Rec
			mov al, 0Dh
			mov ecx, 50
			getRec:
				cmp byte ptr [esi], al
				je RecReadDone
				mov bl, byte ptr [esi]
				mov byte ptr [edi], bl
				inc esi
				inc edi
			loop getRec

			RecReadDone:
			add esi, 2
			push esi
			sub ecx, 50
			neg ecx
			mov szRec, ecx

			mov edi, offset Rec
			mov ecx, 2
			getSecComma:
				push ecx
				mov al, comma
				mov ecx, szRec
				repne scasb
				pop ecx
			loop getSecComma

			push edi
			mov ebx, edi
			mov ecx, 4
			repne scasb
			dec edi
			sub ebx, edi
			neg ebx
			pop edi

			invoke ConvertStringToInt,
				edi, ebx
			mov ebx, intNum
			cmp ebx, maxStudentGrade
			jna skip
			
			mov maxStudentGrade, ebx
			mov esi, offset Rec
			mov edi, offset maxStudentID
			mov al, comma
			mov ecx, 5
			setMaxStudent:
				cmp al, [esi]
				je com
				mov bl, [esi]
				mov [edi], bl
				inc esi
				inc edi
			loop setMaxStudent

			com:
			sub ecx, 5
			neg ecx
			mov szMaxStudentID, ecx

			skip:
			pop esi
			pop ecx
			sub ecx, szRec
			sub ecx, 2
			cmp ecx, 0
			je endCheckAllRec
		jmp checkAllRec
		endCheckAllRec:

		invoke ConvertStringToInt,
			addr maxStudentID, szMaxStudentID

		invoke DisplayTopStudent, intNum
			
		invoke DeleteStudent,
			offset maxStudentID, szMaxStudentID

		pop ecx
		dec ecx
		cmp szBuffer, 0
		je endTop5
		cmp ecx, 0
		je endTop5
	jmp top5

	endTop5:
	mov esi, offset tempBuffer
	mov edi, offset buffer
	mov ecx, szTempBuffer
	mov szBuffer, ecx
	rep movsb

	return:
	ret
DisplayTop5 ENDP

;------------------------------------------------------
;checks the number of students in each section
;------------------------------------------------------ 
CheckStudent PROC
	cmp szBuffer, 0
	je return

	mov ebx, OFFSET buffer
	mov ecx, szBuffer

	mov studentCounter1, 0
	mov studentCounter2, 0

	l:
	push ecx 
		mov al, [ebx]
		cmp al, newline
		je incStudent

		jmp continue
		incStudent:
			sub ebx ,1 
			mov al , [ebx]
			sub al , '0'
			mov cl,  1
			sub cl , al
			cmp cl, 0
			je incStudent1

			jmp incStudent2

			incStudent1:	
			inc studentCounter1
			add ebx , 1 
			jmp continue

			incStudent2:
			inc studentCounter2
			add ebx , 1 

		continue:
		inc ebx
		pop ecx
	loop l

	return:
	ret
CheckStudent endp

;------------------------------------------------------
;Add new student
;Receives: Student(ID, Name, Intger Grade, Section No.)
;------------------------------------------------------ 
EnrollStudent PROC, sID:PTR BYTE, sName:PTR BYTE, sGrade:PTR BYTE, sSecNum:PTR BYTE

	call CheckStudent

	mov eax, sSecNum
	cmp byte ptr [eax], "1"

	je section1
	jmp section2
		
	
	section1:
	cmp studentCounter1, 20
	jb canadd
	jmp Cannotadd

	section2: 
	cmp studentCounter2, 20
	jb canadd
	jmp Cannotadd

	canadd:
	cld
	mov edi, OFFSET buffer
	add edi, szBuffer

	mov esi, sID
	movzx ecx, szID
	add szBuffer, ecx
	rep movsb

	mov esi, offset comma
	mov ecx, 1
	add szBuffer, 1
	rep movsb

	mov esi, sName
	movzx ecx, szName
	add szBuffer, ecx
	rep movsb

	mov esi, offset comma
	mov ecx, 1
	add szBuffer, 1
	rep movsb

	mov esi, sGrade
	movzx ecx, szGrade
	add szBuffer, ecx
	rep movsb

	mov esi, offset comma
	mov ecx, 1
	add szBuffer, 1
	rep movsb

	mov esi, sSecNum
	mov ecx, 1
	add szBuffer, 1
	rep movsb

	mov esi, offset newLine
	mov ecx, 2
	add szBuffer, 2
	rep movsb

	jmp donee
	Cannotadd:
		mwrite <"Can not Enroll Student",0Dh,0Ah>
		mwrite <"The Enrollement is cancelled", 0Dh,0Ah>

	donee:
	ret
EnrollStudent ENDP

;=================================== update Student PROC  ===================================
;-----------------------------------------
; [1] check if File is Empty.
; [2] Read Row (Split At New Line).
; [3] Read The Checked ID and convert it to int .
; [4] Read the student ID That exist in the file and conver it to int .
; [4] check If Studet is Existing.
	; a- if it exist:
		; i. Get Studet Id (Split at First Comma).
		; ii. Get Studet Name (Split at second Comma).
		; iii. Get Studet Grade (Split at third Comma).
		; iv. Get Studet Section .
		; v. write the Id then write comma in the new buffer.
		; vi. write the Name then write comma.
		; vii. write the new Grade then write comma.
		; viii . in the end write the section number the we add newline.
	; b- if it not exist:
		; i. write the Id then write comma.
		; ii. write the Name then write comma.
		; iii. write the Grade then write comma.
		; iv . in the end write the section number the we add newline.
; [4] ReWirte The Buffer for the new buffer.
;-----------------------------------------
UpdateGrade PROC, ID_CHECK:PTR BYTE , New_Grade:PTR BYTE
	cld

		mov ebx, szBuffer
		cmp ebx, 0
		jne File_Is_Not_Empty
		
		mov edx, offset File_Is_Empty
		call writestring
		call crlf
		ret

		File_Is_Not_Empty:

		mov ecx, Target_ID_Size
		mov esi, ID_CHECK
		mov edx, 0
		mov eax , 0 
		mov TheIntNumber2 , 0 
		Read_The_Checked_ID :
			push ecx
			mov eax, [esi + edx]
			mov cl , TheIntNumber2
			imul ecx , 10
			sub al , '0'
			add cl , al
			mov TheIntNumber2 , cl 
			add edx ,1 
			pop ecx
		loop Read_The_Checked_ID

		Main_Loop:

		mov eax, szBuffer
		cmp Row_Offset, eax
		je End_Of_File

		mov ecx, 1
		mov ebx, Row_Offset
		mov edx, 0
		Check_NewLine:
			mov al, [Buffer + ebx]
			cmp al, newLine

			je Row_Without_NewLine

			mov [Row + edx], al
			add Size_Row, 1
			add ebx, 1
			add edx, 1
			add ecx, 1
		loop Check_NewLine

		Row_Without_NewLine:

		mov eax, Size_Row
		add eax, 2
		add Row_Offset, eax

		mov esi , Size_Row
		mov Temp , esi


		mov ecx, Temp
		mov ebx, 0
		mov TheIntNumber , 0 
		Read_Student_Id:
			push ecx
			mov al, [Row + ebx]
			cmp al, comma
			je Finish

			mov ecx , TheIntNumber
			imul ecx , 10
			sub al , '0'
			add ecx , eax
			mov TheIntNumber , ecx 
			add Size_checked_Id, 1
			add ebx, 1

			pop ecx
		loop Read_Student_Id

		Finish: 
	
			movzx esi, TheIntNumber2
			cmp esi , TheIntNumber
			jne Not_The_Same_ID
			jmp The_Same_ID

		Not_The_Same_ID:
			mov ecx, Size_Row
			mov ebx, Size_Update_Buffer
			mov edx, 0
			Write_Row_Of_The_NewBuffer:
				mov al, [Row + edx]
				mov [Update_Buffer + ebx], al
				add Size_Update_Buffer, 1
				add ebx, 1
				add edx, 1
			loop Write_Row_Of_The_NewBuffer

			mov al, 0Dh
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1

			add ebx, 1
			mov al, 0Ah
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1
						
			mov Size_Row, 0
			mov Size_checked_Id, 0

			jmp Main_Loop

		The_Same_ID:

			mov Row_Is_Updated, 1
			mov Size_checked_Id ,0
			mov ebx ,Size_Row
			mov Temp2 , ebx
			mov Temp , 1 
			mov ecx, Size_Row
			mov ebx, 0
			Read_ID_Name_Grade_Sec :
			mov al, [Row + ebx]
			cmp al, comma
			jne continue
			add Temp , 1 
			add ebx , 1
			loop Read_ID_Name_Grade_Sec


			continue:
			cmp ebx , Temp2
			jne cont 
			jmp continue5
			cont :
			cmp temp , 1
			je Read_ID
			jmp continue2
			Read_ID:
			mov edx , ID_Counter
			mov [checked_Id + edx], al
			add Size_checked_Id, 1
			add ID_Counter, 1
			add ebx, 1
			jmp Read_ID_Name_Grade_Sec


			continue2:
			cmp temp , 2 
			je Read_Name
			jmp continue3
			Read_Name:
			mov edx , Name_Counter
			mov [Names + edx], al
			add Size_Name, 1
			add Name_Counter, 1
			add ebx, 1
			jmp Read_ID_Name_Grade_Sec


			continue3 :
			cmp temp , 3 
			je Read_Grade
			jmp continue4
			Read_Grade :
			mov edx , Grade_Counter
			mov [Grades + edx], al
			add Size_Grades, 1
			add Grade_Counter, 1
			add ebx, 1
			jmp Read_ID_Name_Grade_Sec

			continue4:
			cmp temp , 4
			je Read_Sec
			jmp continue5
			Read_Sec:
			mov edx , Section_Counter
			mov [SectiOn+edx] , al
			add Size_SectiOn ,1 
			add ebx , 1
			add Section_Counter , 1
			jmp Read_ID_Name_Grade_Sec


			continue5:

			mov ecx, Size_checked_Id
			mov ebx, Size_Update_Buffer
			mov edx, 0
			Write_ID:
				mov al, [checked_Id + edx]
				mov [Update_Buffer + ebx], al
				add Size_Update_Buffer, 1
				add ebx, 1
				add edx, 1
			loop Write_ID

			mov al , comma
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1
			add ebx, 1

			mov ecx, Size_Name
			mov edx, 0
			Write_Name:
				mov al, [Names + edx]
				mov [Update_Buffer + ebx], al
				add Size_Update_Buffer, 1
				add ebx, 1
				add edx, 1
			loop Write_Name

			mov al , comma
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1
			add ebx, 1

			mov ecx, Target_Grade_Size
			mov edx, 0
			mov esi , New_Grade
			Write_Grade:
				mov al, [esi + edx]
				mov [Update_Buffer + ebx], al
				add Size_Update_Buffer, 1
				add ebx, 1
				add edx , 1
			loop Write_Grade

			mov al , comma
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1
			add ebx, 1
			
			mov ecx , Size_SectiOn
			mov edx , 0
			Write_Section:
			mov al , [SectiOn+edx]
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1
			add ebx ,1
			add edx , 1 
			loop Write_Section

			mov al, 0Dh
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1

			add ebx, 1
			mov al, 0Ah
			mov [Update_Buffer + ebx], al
			add Size_Update_Buffer, 1
						
			mov Size_Row, 0
			mov Size_checked_Id, 0
			mov Size_SectiOn , 0
			mov Size_Name,0
			mov Size_Grades , 0

			jmp Main_Loop
			
		End_Of_File:

			cmp Row_Is_Updated, 1
			je student_Is_Updated

			mov Row_Offset, 0
			mov Size_Update_Buffer, 0

			mov edx, offset Student_Not_Found
			call writestring
			call crlf
			ret

		student_Is_Updated:

			mov Row_Offset, 0

			mwrite "Successfuly Updated ..."
			call crlf

			mov ecx, Size_Update_Buffer
			mov ebx, 0
			Rewrite_Buffer:
				mov al, [Update_Buffer + ebx]
				mov [Buffer + ebx], al
				add ebx, 1
			loop Rewrite_Buffer
			
			mov edx, Size_Update_Buffer
			mov szBuffer, edx
			mov Size_Update_Buffer, 0
			ret

UpdateGrade ENDP

;-----------------------------------------------------------------
; Delete Student PROC
; Receives : Offset Student Id : PTR BYTE
; Return : No thing
;-----------------------------------------------------------------

DeleteStudent PROC, Target_Id:PTR BYTE, Target_Size:DWORD
	cld
		mov ebx, szBuffer
		cmp ebx, 0
		jne Not_Empty
		
		mov edx, offset Empty_File
		call writestring
		call crlf
		ret

		Not_Empty:

		While_Loop:

		mov eax, szBuffer
		cmp Read_Row_Offset, eax
		je File_Is_End

		mov ecx, 1
		mov ebx, Read_Row_Offset
		mov edx, 0
		Cheak_NewLine:
			mov al, [Buffer + ebx]
			cmp al, newLine
			je Row_Is_Read
			mov [Read_Row + edx], al
			add Size_Read_Row, 1
			add ebx, 1
			add edx, 1
			add ecx, 1
		loop Cheak_NewLine

		Row_Is_Read:

		mov eax, Size_Read_Row
		add eax, 2
		add Read_Row_Offset, eax

		mov ecx, Size_Read_Row
		mov ebx, 0
		mov edx, 0
		Read_Studant_Id:
			mov al, [Read_Row + ebx]
			cmp al, comma
			je Break
			mov [Cheak_Id + edx], al
			add Size_Cheak_Id, 1
			add edx, 1
			add ebx, 1
		loop Read_Studant_Id

		Break:

		mov Target_Int, 0

		Invoke ConvertStringToInt, Target_Id, Target_Size
		mov eax, intNum
		mov Target_Int, eax

		Invoke ConvertStringToInt, offset Cheak_Id, Size_Cheak_Id
		mov ebx, intNum
		
		cmp Target_Int, ebx
		je Is_Target

		Not_Target:
			mov ecx, Size_Read_Row
			mov ebx, Size_New_Buffer
			mov edx, 0
			Write_Row_NewBuffer:
				mov al, [Read_Row + edx]
				mov [New_Buffer + ebx], al
				add Size_New_Buffer, 1
				add ebx, 1
				add edx, 1
			loop Write_Row_NewBuffer

			mov al, 0Dh
			mov [New_Buffer + ebx], al
			add Size_New_Buffer, 1

			add ebx, 1
			mov al, 0Ah
			mov [New_Buffer + ebx], al
			add Size_New_Buffer, 1
						
			mov Size_Read_Row, 0
			mov Size_Cheak_Id, 0

			jmp While_Loop

		Is_Target:

			mov Row_Is_Deleted, 1

			mov Size_Read_Row, 0
			mov Size_Cheak_Id, 0

			jmp While_Loop
			
		File_Is_End:

			cmp Row_Is_Deleted, 1
			je Studant_Is_Deleted

			mov Read_Row_Offset, 0
			mov Size_New_Buffer, 0

			mov edx, offset Studant_Not_Found
			call writestring
			call crlf
			ret

		Studant_Is_Deleted:

			mov Row_Is_Deleted, 0
			mov Read_Row_Offset, 0


			mov ah, 1
			;mwrite "Successfuly Deleted ..."
			;call crlf

			cmp Size_New_Buffer, 0
			je Only_One_Studant

			mov ecx, Size_New_Buffer
			mov ebx, 0
			Rwrite_Buffer:
				mov al, [New_Buffer + ebx]
				mov [Buffer + ebx], al
				add ebx, 1
			loop Rwrite_Buffer
			
			mov edx, Size_New_Buffer
			mov szBuffer, edx
			mov Size_New_Buffer, 0
			ret

			Only_One_Studant:
			mov szBuffer, 0
			mov Size_New_Buffer, 0
			ret
DeleteStudent ENDP

;-------------------------------------------------
;Display Student Data by ID
;Recieves: Student ID
;-------------------------------------------------
DisplayStudentData PROC sID:DWORD
	mov esi, offset buffer
	mov ecx, szBuffer

	cmp ecx, 0
	je notFound

	checkAllRec:
		push ecx
		mov edi, offset Rec
		mov al, 0Dh
		mov ecx, 50
		getRec:
			cmp byte ptr [esi], al
			je RecReadDone
			mov bl, byte ptr [esi]
			mov byte ptr [edi], bl
			inc esi
			inc edi
		loop getRec

		RecReadDone:
		add esi, 2
		push esi
		sub ecx, 50
		neg ecx
		mov szRec, ecx

		;check is the same id or not
		mov esi, offset Rec
		mov al, comma
		mov ecx, szRec
		checkID:
			cmp byte ptr [esi], al
			je outCheckID
			inc esi
		loop checkID
		outCheckID:
		sub ecx, szRec
		neg ecx
		mov edx, ecx
		mov esi, offset rec
		invoke ConvertStringToInt,
			esi, edx
		mov eax, intNum
		cmp eax, sID
		jne notID
		mov ebx, 1
		jmp ID
		notID:
		mov ebx, 0
		ID:
		pop esi
		pop ecx
		sub ecx, szRec
		sub ecx, 2
		cmp ebx, 1
		je endCheckAllRec
		cmp ecx, 0
		je endCheckAllRec
	jmp checkAllRec
	endCheckAllRec:

	cmp ebx, 1
	jne notFound
	Found:
		mov esi, offset Rec
		mov edi, offset Rec
		mov ecx, szRec
		coutID:
			cmp byte ptr [edi], ','
			je outCoutID
			inc edi
		loop coutID
		outCoutID:
		mov byte ptr [edi], 0
		mov edx, esi
		mWrite "Student ID: "
		call writestring
		call crlf
		inc edi
		mov esi, edi

		coutName:
			cmp byte ptr [edi], ','
			je outCoutName
			inc edi
		loop coutName
		outCoutName:
		mov byte ptr [edi], 0
		mov edx, esi
		mWrite "Student Name: "
		call writestring
		call crlf
		inc edi
		mov esi, edi

		coutGrade:
			cmp byte ptr [edi], ','
			je outCoutGrade
			inc edi
		loop coutGrade
		outCoutGrade:
		mov byte ptr [edi], 0
		mov edx, esi
		mWrite "Student Grade: "
		call writestring
		call crlf
		inc edi
		mov esi, edi
		
		inc edi
		mov byte ptr [edi], 0
		mov edx, esi
		mWrite "Student Section: "
		call writestring
		call crlf
	ret

	notFound:
		mWrite <"Not Found ID", 0Dh, 0Ah>
	ret
DisplayStudentData ENDP

;--------------------------------------
;Open Database File
;Receives: file name parameter
;Returns: EAX contains buffer size
;--------------------------------------
OpenDatabase PROC uses eax edx ecx, fileN:PTR BYTE, bKey:BYTE
	INVOKE CREATEFILE, 
		fileN, GENERIC_READ, DO_NOT_SHARE, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0

	mov fileHandle, eax
	mov edx, OFFSET buffer
	mov ecx, BUFFER_SIZE
	call READFROMFILE
	mov szBuffer, eax
	
	cmp szBuffer, 0
	je close
	
	dec szBuffer

	mov eax, offset buffer
	add eax, szBuffer
	mov dl, byte ptr [eax]
	xor dl, 11110000b
	cmp dl, bKey
	jne notKey

	mov edx, offset buffer
	mov ecx, szBuffer
	decrypt:
		mov al, [edx]
		xor al, bKey
		mov [edx], al
		inc edx
	loop decrypt

	mWrite "Database Open Successfully!"
	call crlf
	jmp close

	notKey:
	mWrite "Incorrect Database Key!"
	call crlf
	mov ebx, 1

	close:
	mov eax, fileHandle
	call CLOSEFILE

	ret
OpenDatabase ENDP

;-------------------------------------
;Receives: file name parameter
;-------------------------------------
SaveDatabase PROC, fileN:PTR BYTE
	INVOKE CREATEFILE, 
		fileN, GENERIC_WRITE, DO_NOT_SHARE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0

	mov fileHandle, eax
	mov edx, OFFSET buffer
	mov ecx, szBuffer
	call WRITETOFILE

	mov eax, fileHandle
	call CLOSEFILE

	ret
SaveDatabase ENDP

;------------------------------------------------
;Receives: file name parameter and Database Key
;------------------------------------------------
SaveDatabaseWithKey PROC, fileN:PTR BYTE, bKey:BYTE
	INVOKE CREATEFILE, 
		fileN, GENERIC_WRITE, DO_NOT_SHARE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov fileHandle, eax

	cmp szBuffer, 0
	je close

	mov eax, offset buffer
	add eax, szBuffer
	mov dl, bKey
	xor dl, 11110000b
	mov byte ptr [eax], dl

	mov edx, offset buffer
	mov ecx, szBuffer
	encrypt:
		mov al, [edx]
		xor al, bKey
		mov [edx], al
		inc edx
	loop encrypt

	mov eax, fileHandle
	mov edx, OFFSET buffer
	mov ecx, szBuffer
	inc ecx
	call WRITETOFILE

	close:
	mov eax, fileHandle
	call CLOSEFILE

	ret
SaveDatabaseWithKey ENDP

main proc
	mov eax, 0
	mWrite "Please Enter Database Key:"
	call readchar
	mov Key, al
	mov al, '*'
	call writechar
	call crlf
	invoke OpenDatabase, 
		ADDR fileName, Key

	cmp ebx, 1
	je closeApp

	begin:
		mWrite <"=================================", 0Dh, 0Ah>
		mwrite <"[1] Enroll Student.", 0Dh, 0Ah>
		mwrite <"[2] Update Grade.", 0Dh, 0Ah>
		mwrite <"[3] Delete Student.", 0Dh, 0Ah>
		mwrite <"[4] Display Student Data.", 0Dh, 0Ah>
		mwrite <"[5] Display Top 5 Students.", 0Dh, 0Ah>
		mwrite <"[6] Generate Section Report.", 0Dh, 0Ah>
		mwrite <"[7] Exit.", 0Dh, 0Ah>
		mWrite <"=================================", 0Dh, 0Ah>
		mwrite "Please select: "
		call readdec
		cmp eax, 1
		je l1
		cmp eax, 2
		je l2
		cmp eax, 3
		je l3
		cmp eax, 4
		je l4
		cmp eax, 5
		je l5
		cmp eax, 6
		je l6
		cmp eax, 7
		je quit
		jmp begin

	l1:;------------------------------------------------------add new student
		mWrite <"================", 0Dh, 0Ah>
		mwrite <"ADD NEW STUDENT", 0Dh, 0Ah>
		mWrite <"================", 0Dh, 0Ah>
		mwrite "Student ID:"
		mov edx, OFFSET studentID
		mov ecx, LENGTHOF studentID
		call readstring
		mov szID, al
		mwrite "Student Name:"
		mov edx, OFFSET studentName
		mov ecx, LENGTHOF studentName
		call readstring
		mov szName, al
		mwrite "Student Grade:"
		mov edx, OFFSET grade
		mov ecx, LENGTHOF grade
		call readstring
		mov szGrade, al
		mwrite "Student Section No.:"
		mov edx, OFFSET secNumber
		mov ecx, LENGTHOF secNumber
		call readstring


		invoke EnrollStudent, 
			addr studentID, addr studentName, addr grade, addr secNumber

	jmp begin
	
	l2:;------------------------------------------------------update student grade
		mov edx, offset Get_Student_Id 
		call writestring

		mov edx , offset studentID
		mov ecx, LENGTHOF studentID
		call readstring
		mov Target_ID_Size , eax

		mov edx , offset Get_Student_Name
		call writestring 


		mov edx , offset grade
		mov ecx , LENGTHOF grade
		call readstring 
		mov Target_Grade_Size ,eax 


		invoke UpdateGrade,
			offset studentID , offset grade

	jmp begin

	l3:;------------------------------------------------------delete student
		mov edx, offset Get_Studant_Id
		call writestring

		mov edx, OFFSET studentID
		mov ecx, LENGTHOF studentID
		call readstring

		invoke DeleteStudent,
			offset studentID, eax

		cmp ah, 1
		jne outDelete
		mWrite "Successfuly Deleted ..."
		call crlf

	outDelete:
	jmp begin

	l4:;------------------------------------------------------display student data
		mWrite "Please Enter Student ID:"
		call readdec

		invoke DisplayStudentData,
			eax
	jmp begin

	l5:;------------------------------------------------------display top 5 students
		call DisplayTop5
	jmp begin

	l6:;------------------------------------------------------generate section report
		mov edx, offset Get_Sec_Number
		call writestring

		call readchar
		call writechar
		mov Read_Sec_Number, al
		Invoke Generate_Section_Report, Read_Sec_Number
	jmp begin

	quit:
	INVOKE SaveDatabaseWithKey,
		ADDR fileName, Key
	
	closeApp:
	exit
main endp

end main