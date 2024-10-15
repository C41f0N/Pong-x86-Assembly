INCLUDE irvine32.inc

.data
	; // Screen Info
	screenHeight DWORD 20;
	screenWidth DWORD 80;

	borderPixel DWORD 'O';
	backgroundPixel DWORD ' ';
	playerPixel DWORD 'o';

	; // Players info
	player1 DWORD ?;
	player2 DWORD ?;
	
.code
	; // Function to render the screen
	renderScreen PROC
		
		MOV dh, 0;
		MOV dl, 0;
		CALL goToXY;

		MOV ecx, screenHeight;
	
		loop1:
			MOV ebx, ecx;
			MOV ecx, screenWidth;

			loop2:
			
				CMP ecx, 1;
				JE isBorder;

				CMP ecx, screenWidth;
				JE isBorder;

				CMP ebx, 1;
				JE isBorder;

				CMP ebx, screenHeight;
				JE isBorder;

				JMP isNotBorder;

				isBorder:
					MOV eax, borderPixel;
					JMP printPixel;
				
				isNotBorder:
					CMP ebx, player1;
					JNE isEmpty;

					MOV eax, screenWidth;
					SUB eax, 1;
					CMP ecx, eax;
					JE isPlayer;

					CMP ecx, 2;
					JE isPlayer;

					JMP isEmpty;
				
					isEmpty:
						MOV eax, backgroundPixel;
						JMP printPixel;

				isPlayer:
					MOV eax, playerPixel;
					JMP printPixel;

				printPixel:
					CALL writeChar;

			LOOP loop2;
		
			CALL crlf;
			MOV ecx, ebx;
		LOOP loop1;

		ret;
	renderScreen ENDP

	main PROC

		MOV player1, 10;
		MOV player2, 10;

		loop1:
			CALL renderScreen;
			CALL readKey;

			CMP dx, 26h;
			JE up;

			CMP dx, 28h; 
			JE down;

			JMP nothingPressed;

			down:
				MOV eax, player1;
				INC eax;
				CMP eax, 2;
				JNL moveDown;
				JMP nothingPressed;

				moveDown:
					DEC player1;
				JMP nothingPressed;

			up:
				INC player1;
				JMP nothingPressed;

			nothingPressed: 

			MOV eax, 33;

			CALL delay;
			
		LOOP loop1;


	main ENDP
	END main