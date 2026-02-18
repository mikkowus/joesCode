;
;      Tic Tac Toe!
;   By - Spikerocks101
;   Date - 04/23/2020
;
; Made during the Covid-19 quarantine for fun
; Program functionally allows you to play Tic Tac Toe
; AI only randomly guesses spots (yet, it feels like it tries to lose)
; 
; Made on Windows 10 in vsCode
; Assembly built with NASM 86x
; EXE built with Mingw 86x, POSIX, GCC
;
; forum -> reddit.com/r/asm
;

; basic print, scan and time imports
extern _printf, _scanf, _time
global _main

section .data
	debugs db "debug", 10, 0			; used for scanf
	FORMAT_INPUT db "%c", 0			; used for scanf
	NEWLINE_STRING db 10, 0			; used for new lines
	; ingame messages, mostly self explanitory
	s_msg db "Want to play again ('y' or 'n')? ", 0
	s_intro db "Welcome to Tic Tac Toe!", 10, 0
	s_choosepiece db "Would you like to be X or O? ('x' or 'o'): ", 0
	s_chosex db "You chose X! You will go first!", 10, 0
	s_choseo db "You chose O! You will go second!", 10, 0
	s_choosespot db "Where would you like to put a piece? ", 0
	s_outofrange db "Please choose a number from 1 to 9.", 10, 0
	s_spottaken db "Please choose a spot that is not taken.", 10, 0
	s_aiplaceat db "AI placed a piece at cell %d.", 10, 0
	s_win db "You Win!", 10, 0
	s_lose db "You Lose!", 10, 0
	s_tie db "Cat's game, it's a tie!", 10, 0
	; board takes 9 byte chars, that will be either a number, a 'x' or a 'o'
	s_board db " %c | %c | %c",10,"-----------", 10, " %c | %c | %c", 10, "-----------", 10, " %c | %c | %c", 10, 0
	; INRES stores a single char byte from scanf prompt (should never be set, only read)
	INRES db 0

section .bss
	i_loop resb 1
	i_xo resb 9 					; 9 byte string that holds the gameboard with either a number, 'x' or 'o'
	i_player resb 1 				; players piece, 0 = no piece, 1 = 'x', 2 = 'o'
	i_wintype resb 1 				; tells how the winner won (what row/column/cross the got to win), 0 = not won yet
	i_aiseed resd 1 				; gives the ai randomness, not a true random seed, but close enough
	i_catsgame resd 1 				; if there is a cats game, it gets set to 1, otherwise it is always 0
	i_aigoesfirst resd 1			; if player chooses 'o' piece, ai will go first
	i_ailoopcount resd 1 			; cause the ai ain't well programmed,
						 			; this will brute force an ai move so the game doesn't get locked
section .text

;------------------------ C Entery Point ------------------------

_main:

	push	0						; set a default null
	mov ebp, esp					; set stack start
	call gamestart					; goto gamestart
	push 0							; exit code 0
	call exit						; end program

;------------------------ Program Close ------------------------

exit:								; clean up then exit program
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointer
	push ebx						; save register
	mov eax, 1						; system call number for exit
	mov ebx, [ebp+8]				; system call number for exit code
	int 0x80						; goodbye!
	pop	ebx							; restore register
	leave							; clean up before exiting
    ret								; return to the abyss!

;------------------------ Newline ------------------------
; easy way to make new lines, just type 'call newline'

newline:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointer
	push NEWLINE_STRING				; string thats just 10. 0
	call _printf					; print message
	add esp, 4						; free stack
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Char Input ------------------------
; scans for user input of a single char. will cycle if they respond with an blank line

charinput:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointer
.getinput:							; cycles getinput until user enters valid input
	mov [INRES], byte 0				; clears INRES
	push INRES						; push INRES to stack to get set
	push FORMAT_INPUT				; format for setting INRES
	call _scanf						; sets INRES
	add esp, 8						; frees stack
	cmp [INRES], byte 10			; if user posts newline (10), reask for input
	je .getinput
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Game Start ------------------------
; starts new game, can be called to create new game

gamestart:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointer
	; clear game variables
	mov [i_loop], byte 0
	mov [i_player], byte 0
	mov [i_wintype], byte 0
	mov [i_catsgame], byte 0
	mov [i_ailoopcount], byte 0
	mov [i_aigoesfirst], byte 0
	; generates new aiseed from time
	push i_aiseed					; push aiseed to get set
	call _time						; call time
	add esp, 4						; free stack
	call createboard				; creates an empty board in i_xo
	push s_intro					; welcome to tic tac toe message
	call _printf					; print message
	add esp, 4						; free stack
	call newline					; newline
.getinput:							; cycle here until valid input
	push s_choosepiece				; prompt user to choose 'x' or 'o'
	call _printf					; print message
	add esp, 4						; free stack
	call charinput					; get input char byte from user
	call newline					; newline after input
	; user can choose 'x' or 'o', but its currently case sensitive
	cmp [INRES], byte 'x'			; if x, set player to 'x'
	je .chosex
	cmp [INRES], byte 'o'			; if o, set player to 'o'
	je .choseo
	jmp .getinput					; if neither, prompt user again
.chosex:							; set players piece to 'x'
	mov [i_player], byte 'x'		; set piece mov
	push s_chosex					; push message 'you chose x'
	jmp .continue					; skip 'choseo'
.choseo:							; set players piece to 'o'
	mov [i_player], byte 'o'		; set piece move
	mov [i_aigoesfirst], byte 1		; since player chose 'o', ai will go first
	push s_choseo					; push message 'you chose y'
.continue:							; contiue with function
	call _printf					; prints the 'you chose' message
	add esp, 4						; free stack
	call newline					; newline
.mainloop:							; main game loop
	call gameloop					; call loop interation
	jmp .mainloop					; keep repeating
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Create Board ------------------------
; Creates the initial board with numbers

createboard:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser

	mov eax, 1						; counter for loop, repeats 9 times
	mov ebx, i_xo					; loads board
.loopboard:							; board loop
	mov [ebx], al					; sets board piece to counter
	add byte [ebx], 48				; turns number to ascii version
	inc ebx					 		; inc to next board piece
	inc eax							; inc counter
	cmp eax, 10						; if counter is 10, leave
	jne .loopboard	
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Render Board ------------------------
; Renders game board to screen
; First it pushs all the pieces to memory (s_xo)
; Second it pushs board template to memory
; Third it prints the board. Will look like:
;
;	 1 | 2 | 3
;	-----------
;	 4 | 5 | 6
;	-----------
;	 7 | 8 | 9
;

renderboard:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser
	mov eax, 9						; eax is the counter for the loop
	mov ebx, i_xo					; sets ebx to the pieces string
	add ebx, 8						; gets the last piece first
.loopboard:							; goes through each piece
	push dword [ebx]				; pushs piece to memory
	dec ebx							; goes to next piece
	dec eax							; loop counter decreases
	cmp eax, 0						; if 0, end of loop
	jne .loopboard					; loop jmp
	push s_board					; push the board string template
	call _printf					; prints board
	add esp, 4						; clean up board
	add esp, 4*9					; clean up the 9 spots
	call newline					; prints new line
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Check Win ------------------------
; Check to see if player has won
; argument 0: piece (either 'x' or 'o')
; Grid looks like this
;
;	0 | 1 | 2
;	3 | 4 | 5
;	6 | 7 | 8
;
;	Win Type Matches
;	#	|	Description		|	Cells
;	1	|	top row			|	(0, 1, 2)
;	2	|	middle row		|	(3, 4, 5)
;	3	|	bottom row		|	(6, 7, 8)
;	4	|	left column		|	(0, 3, 6)
;	5	|	middle column	|	(1, 4, 7)
;	6	|	right column	|	(2, 5, 8)
;	7	|	forward slash 	|	(6, 4, 2)
;	8	|	back slash		|	(0, 4, 8)

checkwin:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser

	mov eax, [esp+8]				; load piece to eax register
	mov ebx, 0						; clears ebx incase its used

	; top row, wintype 1
	mov bl, [i_xo+0]				; set cell to bl register
	and bl, [i_xo+1]				; ands the two cells together
	and bl, [i_xo+2]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .middlerow					
	mov [i_wintype], byte 1			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; middle row, wintype 2
.middlerow:
	mov bl, [i_xo+3]				; set cell to bl register
	and bl, [i_xo+4]				; ands the two cells together
	and bl, [i_xo+5]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .bottomrow
	mov [i_wintype], byte 2			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; bottom row, wintype 3
.bottomrow:
	mov bl, [i_xo+6]				; set cell to bl register
	and bl, [i_xo+7]				; ands the two cells together
	and bl, [i_xo+8]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .leftcolumn
	mov [i_wintype], byte 3			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; left column, wintype 4
.leftcolumn:
	mov bl, [i_xo+0]				; set cell to bl register
	and bl, [i_xo+3]				; ands the two cells together
	and bl, [i_xo+6]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .middlecolumn
	mov [i_wintype], byte 4			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; middle column, wintype 5
.middlecolumn:
	mov bl, [i_xo+1]				; set cell to bl register
	and bl, [i_xo+4]				; ands the two cells together
	and bl, [i_xo+7]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .rightcolumn
	mov [i_wintype], byte 5			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; right column, wintype 6
.rightcolumn:
	mov bl, [i_xo+2]				; set cell to bl register
	and bl, [i_xo+5]				; ands the two cells together
	and bl, [i_xo+8]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .forwardslash
	mov [i_wintype], byte 6			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; forward slash, wintype 7
.forwardslash:
	mov bl, [i_xo+6]				; set cell to bl register
	and bl, [i_xo+4]				; ands the two cells together
	and bl, [i_xo+2]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .backslash
	mov [i_wintype], byte 7			; player won, so set wintype
	jmp .skip						; skip the rest of the checks
	; back slash, wintype 8
.backslash:
	mov bl, [i_xo+0]				; set cell to bl register
	and bl, [i_xo+4]				; ands the two cells together
	and bl, [i_xo+8]				; ands the three cells together
	cmp al, bl						; if not a match with player's piece, go to next wintype
	jne .skip						; skip the rest of the checks
	mov [i_wintype], byte 8			; player won, so set wintype
.skip:								; end label
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Cats Game ------------------------
; A cats game happens if the board is full but no player wins
; It will be called a Tie

catsgame:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser

	mov eax, 0						; counter to cycle board, counters 9 times
	mov ebx, i_xo					; load board
.boardcheck:						; board loop
	cmp eax, 9						; if counter is 9, means all cells have been checked
	je .declarecatsgame				; if all cells have been checked, it must be a cats game
	cmp [ebx], byte 'x'				; sees if current spot is the 'x' piece
	je .pieceplaced					; if so, goto next cell
	cmp [ebx], byte 'o'				; sees if current spot is the 'x' piece			
	je .pieceplaced					; if so, goto next cell
	jmp .nocatsgame					; if any cell doesn't have a piece, it isn't a cats game (yet! :O)
.pieceplaced:						; since a piece was found, go to next cell
	inc eax							; inc counter
	inc ebx							; inc cell
	jmp .boardcheck					; go back to board loop
.declarecatsgame:					; it's a cats game! "The only winning move is not to play"
	mov [i_catsgame], byte 1		; set cats game true
	jmp .end						; end cats games function
.nocatsgame:						; not a cats game, so continue
	mov [i_catsgame], byte 0		; set cats game to false (still, should be false already)				
.end:
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Game Loop ------------------------
; Main game loop. Ordr is something like
; 1 -> Render board
;	* if player chose 'o', skip to # on first iteration
; 2 -> Player places piece
; 3 -> Check if player won
; 4 -> Check if cats game
; 5 -> AI places piece (brutally, eeeek)
; 6 -> Check if AI won
; 7 -> Check if cats games
; 
; If game ends from win/lose/tie, render board
; Ask player if the want to play again after gameover
;

gameloop:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser
	cmp [i_aigoesfirst], byte 1		; if ai goes first (player is 'o'), go to AI on first turn
	jne .showboard					; skip this since it is false (either happened or player is 'x')
	mov [i_aigoesfirst], byte 0		; set to false
	jmp .aimoveloop					; jump to AI turn
.showboard:							; show board
	call renderboard				; renders the game board
.getinput:							; prompt user for place to put users piece
	push s_choosespot				; prints message 'choose a spot'
	call _printf					; print message
	add esp, 4						; free stack
	call charinput					; get input to INRES
	call newline					; newline
	; is number from 1 to 9?
	cmp [INRES], byte 48			; char byte is not with range '0' (48) to '9'
	jl .outofrange					; tell user bad input
	cmp [INRES], byte 57			; char byte is not with range '0' to '9' (59)
	jg .outofrange					; tell user bad input
	; is location valid?
	mov eax, 0						; clear eax, since we'll be using just al
	mov al, [INRES]					; set eax to user input
	push eax						; store input for use
	sub dword [esp], 49				; ascii number to actual number
	mov ebx, i_xo					; load board
	add ebx, [esp]					; find board call (pointer + offset)
	cmp [ebx], byte 'x'				; see if there is already a 'x' piece there
	je .spottaken					; if so, prompt user for another spot
	cmp [ebx], byte 'o'				; see if there is already a 'o' piece there
	je .spottaken					; if so, prompt user for another spot
	; since spot is valid, set player's piece
	mov ecx, 0						; clear ecx since we'll just be using cl
	mov cl, [i_player]				; set player's piece to ecx register (either 'x' or 'o')
	mov [ebx], cl					; set spot to player's piece
	jmp .endgetinput				; got input and cell set, so leave user input
.outofrange:						; if location is out of range, reask for spot
	push s_outofrange				; promput user that the input was bad
	call _printf					; print message
	add esp, 4						; free stack
	call newline					; newline
	jmp .getinput					; getinput loop
.spottaken:							; if spot has piece already, reask for spot
	push s_spottaken				; promput user that the cell was taken
	call _printf					; print message
	add esp, 4						; free stack
	call newline					; newline
	jmp .getinput					; getinput loop	
.endgetinput:						; end of users turn
	push dword [i_player]			; push users piece to stack to see if they won
	call checkwin					; check win function
	add esp, 4						; free stack
	cmp [i_wintype], byte 0			; if they won with any win type (great than 0)...
	jg playerwon					; goto player won
	jmp .checkplayercatsgame		; else, continue to check for cats game
.checkplayercatsgame:				; check to see if players move caused a cats game
	call catsgame					; check for cats game
	cmp [i_catsgame], byte 1		; if true, goto cats game tie gameover
	je catsgameover				; jump to gameover
	; begin of AI's turn
	mov [i_ailoopcount], byte 100	; a counter, used to prevent infinte 'place piece' loop
.aimoveloop:						; AI find place to put piece loop
	cmp [i_ailoopcount], byte 0		; see if counter is 0
	je .aifailed					; if so, goto brute force placement
	dec byte [i_ailoopcount]		; dec counter
	; Code below is increase the random seed to a new random number
	; It isn't true random, but good enough for tic tac toe
	; Formula for new number is:
	; new number += (((old number mod 8191) + 17) / 2) mod 1,700,000,000
	mov eax, [i_aiseed]				; load seed
	mov ebx, eax					; store initial seed
	mov ecx, 8191					; set divisor
	mov edx, 0						; clear mod
	div ecx							; divid (we only want the mod)
	add edx, 17						; add to mod result
	sar edx, 1						; divid by 2 (irony of not using div for this, lol)
	add ebx, edx					; add amount to initial seed value
	mov eax, edx					; load new seed value again
	mov edx, 0						; clear mod
	mov ecx, 1700000000				; set filter on what seed can get to
	div ecx							; div again (poor div command, only used to get the mod, never the quotient)
	mov [i_aiseed], edx				; update seed with filtered amount
	mov eax, edx					; set eax to current seed
	; random spot = seed mod 9
	mov edx, 0						; clears mod
	mov ecx, 9						; board is only 9 big, so set to 9
	div ecx 						; edx now holds ai spot to choose	
	mov eax, i_xo					; load board
	add eax, edx					; choose spot
	cmp byte [eax], 'x'				; see if there is already a 'x' piece there
	je .aimoveloop					; if so, randomly choose another spot
	cmp byte [eax], 'o'				; see if there is already a 'o' piece there
	je .aimoveloop					; if so, randomly choose another spot
	push eax						; since this cell is open, push cell location to stack
	mov eax, 0						; clear eax since we'll just be using al
	mov al, [i_player]				; get players piece
	cmp al, byte 'x'				; if player is 'x', ai will be 'o'
	je .aiplaceso					; goto ai places 'o' labal
	cmp al, byte 'o'				; if player is 'x', ai will be 'x'
	je .aiplacesx					; goto ai places 'x' labal
	; shouldn't get here, RIP if do
.aifailed: 							; the ai fails sometimes, so this just brute forces a cell
	mov ebx, i_xo					; load board
	dec ebx							; we will be inc in a second, so dec right now
.aifailedloop:						; brute force loop
	inc ebx							; get next cell
	cmp [ebx], byte 'x'				; if taken by 'x', go agian
	je .aifailedloop				; back to brute force loop
	cmp [ebx], byte 'o'				; if taken by 'o', go agian
	je .aifailedloop				; back to brute force loop
	push ebx						; since this cell is open, push cell location to stack
	mov eax, 0						; clear eax, since we'll just be using al
	mov al, [i_player]				; get players piece
	cmp al, byte 'x'				; if player is 'x', ai will be 'o'
	je .aiplaceso					; goto ai places 'o' labal
	cmp al, byte 'o'				; if player is 'x', ai will be 'x'
	je .aiplacesx					; goto ai places 'x' labal
.aiplaceso:							; ai places 'o' piece in cell
	mov eax, [esp]					; retrieve cell location from stack
	mov [eax], byte 'o'				; set location to ai's piece 'o'
	push 'o'						; push piece for checkwin in a bit
	jmp .endofai					; goto endofai to skip ai place x
.aiplacesx:							; ai places 'o' piece in cell
	mov eax, [esp]					; retrieve cell location from stack
	mov [eax], byte 'x'				; set location to ai's piece 'x'
	push 'x'						; push piece for checkwin in a bit
.endofai:							; end of the ai logic, now set piece and check win
	call checkwin					; check to see if the ai won (big if tru)
	add esp, 4						; free stack
	cmp [i_wintype], byte 0			; if wintype is greater than 0, the ai won
	jg aiwon						; ai won, what a terrible player... the shame...
	mov eax, 0						; clear eax, since we'll just be using al
	mov al, byte [esp]				; get the location of the ai's new piece
	sub al, 52						; increment it to match visual style (from 0-8 to 1-9)
	push eax						; push eax to prompt
	push s_aiplaceat				; prompt user where the ai placed a piece
	call _printf					; print message
	add esp, 12						; free stack
	call newline					; newline
	jmp .checkaicatsgame			; check if the ai dug the game into a cats game
.checkaicatsgame:					; check for cats game
	call catsgame					; call cats game checker
	cmp [i_catsgame], byte 1		; if true, game over, ended in draw
	je catsgameover					; goto catsgameover
	jmp .end						; else, go to gameloop end, getting ready for next turn
.end:								; game loop end
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Player Won ------------------------

playerwon:							; player has won! woot!
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser	
	call renderboard				; show the board one more time
	call newline					; new line
	push s_win						; prompt user that they won
	call _printf					; print message
	add esp, 4						; free stack
	call newline					; new line
	jmp playagain					; goto play again prompt
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ AI Won ------------------------

aiwon:								; the ai won, player is trash
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser
	call renderboard				; show the board one more time
	call newline					; new line
	push s_lose						; prompt user they lost
	call _printf					; print message
	add esp, 4						; free stack
	call newline					; new line
	jmp playagain					; goto play again prompt
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Cats Game ------------------------

; This is a tie
catsgameover:						; cats game happened, so its a tie	
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser	
	call renderboard				; show the board one more time
	call newline					; new line
	push s_tie						; prompt user that it's a tie
	call _printf					; print message
	add esp, 4						; free stack
	call newline					; new line
	jmp playagain					; goto play again prompt
	leave							; clean up before leaving function
    ret								; return to the abyss!

;------------------------ Play Again? ------------------------

playagain:
	push ebp						; return pointer
	mov ebp, esp 					; set function start pointser	
.getinput:							; get play again prompt loop
	push s_msg						; prompt user if they want to play again
	call _printf					; print message
	add esp, 4						; free stack
	call charinput					; get user response (expect 'y' or 'n')
	call newline					; new line
	call newline					; new line
	cmp [INRES], byte 'y'			; if 'y', then goto game start for a new game
	je gamestart					; goto gamestart
	cmp [INRES], byte 'n'			; if 'n', then they must be going then
	je exit							; leave
	jmp .getinput					; if neither, prompt them again!
	leave							; clean up before leaving function

    ret								; return to the abyss!
