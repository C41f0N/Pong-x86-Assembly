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

	playerOffset = 2;
	playerWidth = 2;
	
	; // Ball info
	ballx DWORD ?;
	bally DWORD ?;

	; // Key info
	upKey = 26h;
	downKey = 28h;
	quitKey = 51h;

.code
	; // Function to render the screen
	renderScreen PROC
		
		MOV dh, 0;
		MOV dl, 0;
		CALL goToXY;

		MOV ecx, screenHeight;
		MOV esi, 0;
	
		everyRow:
			MOV ebx, ecx;
			MOV ecx, screenWidth;
			MOV edi, 0;

			everyPixel:
			
				; Checking if the pixel is a border or not
				CMP edi, 0;
				JE isBorder;

				MOV edx, screenWidth;
				DEC edx;
				CMP edi, edx;
				JE isBorder;

				CMP esi, 0;
				JE isBorder;


				MOV edx, screenHeight;
				DEC edx;
				CMP esi, edx;
				JE isBorder;

				JMP isNotBorder;

				isBorder:
					MOV eax, borderPixel;
					JMP printPixel;
				
				isNotBorder:
					
					; Check if player 1
					
					MOV ebx, player1;
					SUB ebx, playerWidth;

					CMP esi, ebx;
					JLE notPlayer1;

					MOV ebx, player1;
					ADD ebx, playerWidth;

					CMP esi, ebx;
					JGE notPlayer1;

					CMP edi, playerOffset;
					JNE notPlayer1;

					JMP isPlayer;
					
					; If not player 1, then check if player 2
					notPlayer1:
						CMP esi, player2;
						JNE notPlayer2;

						MOV edx, screenWidth;
						SUB edx, playerOffset;
						DEC edx;

						CMP edi, edx;
						JNE notPlayer2;
					JMP isPlayer;

					notPlayer2:
						; Check if ball
					
					JMP isEmpty;

					isEmpty:
						MOV eax, backgroundPixel;
					JMP printPixel;

					isPlayer:
						MOV eax, playerPixel;
					JMP printPixel;

				printPixel:
					CALL writeChar;

			INC edi;
			CMP edi, screenWidth;
			JL everyPixel;
		
			CALL crlf;
			MOV ecx, ebx;

		INC esi;
		CMP esi, screenHeight;
		JL everyRow;

		ret;
	renderScreen ENDP

	handleInput PROC

		CALL readKey;

		CMP dx, upKey;
		JE up;

		CMP dx, downKey; 
		JE down;

		CMP dx, quitKey;
		JE quit;

		JMP done;

		up:
			MOV ebx, 0;
			ADD ebx, playerWidth;
			CMP player1, ebx;
			JLE done;

			DEC player1;
		JMP done;

		down:
			MOV ebx, screenHeight;
			DEC ebx;
			SUB ebx, playerWidth;
				
			CMP player1, ebx;
			JGE done;

			INC player1;
		JMP done;

		quit:
			CALL clrScr;
			exit;
		JMP done;

		done: 

		ret;
	handleInput ENDP
	
	initialize PROC
		MOV player1, 10;
		MOV player2, 10;

		MOV ebx, 2;
		MOV eax, screenWidth;
		MOV edx, 0;
		DIV ebx;
		MOV ballX, eax;

		MOV eax, screenHeight;
		MOV edx, 0;
		DIV ebx;
		MOV ballY, eax;
		
		ret;
	initialize ENDP

	main PROC

		CALL initialize;
		
		gameLoop:

			CALL renderScreen;
			CALL handleInput;
			CALL dumpRegs;

			MOV eax, 33;

			CALL delay;
			
		JMP gameLoop;


	main ENDP
	END main