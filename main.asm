INCLUDE irvine32.inc

.data
	; // Screen Info
	screenHeight = 20;
	screenWidth = 80;

	pixels BYTE screenHeight DUP(screenWidth DUP(?));

	borderPixel BYTE 'X';
	backgroundPixel BYTE ' ';
	playerPixel BYTE '|';
	ballPixel BYTE 'O'

	; // Players info
	player1 DWORD ?;
	player2 DWORD ?;

	playerOffset = 2;
	playerWidth = 2;
	
	; // Ball info
	ballx DWORD ?;
	bally DWORD ?;

	velx DWORD -1;
	vely DWORD 1;

	; // Key info
	upKey = 26h;
	downKey = 28h;
	quitKey = 51h;

.code
	
	; // Function to display the screen
	displayScreen PROC
		
		MOV dh, 0;
		MOV dl, 0;
		CALL goToXY;

		MOV esi, 0;
		everyRow:

			MOV edi, 0;

			everyPixel:

				MOV ebx, eax;

				MOV eax, esi;
				MOV ecx, screenWidth;
				MUL ecx;
				ADD eax, edi;

				XCHG eax, ebx;

				MOVZX eax, [pixels + ebx];

				CALL writeChar;

			INC edi;
			CMP edi, screenWidth;
			JS everyPixel;

			CALL crlf;

		INC esi;
		CMP esi, screenHeight;
		JL everyRow;


		ret;
	displayScreen ENDP

	; // Function to render the screen
	renderScreen PROC
		
		MOV dh, 0;
		MOV dl, 0;
		CALL goToXY;

		MOV esi, 0;
		everyRow:
			MOV edi, 0;
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
					MOVZX eax, borderPixel;
					JMP storePixel;
				
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
						CMP esi, ballY;
						JNE isEmpty;

						CMP edi, ballX;
						JNE isEmpty;

						MOVZX eax, ballPixel;

					JMP storePixel;

					isEmpty:
						MOVZX eax, backgroundPixel;
					JMP storePixel;

					isPlayer:
						MOVZX eax, playerPixel;
					JMP storePixel;

				storePixel:
					MOV ebx, eax;

					MOV eax, esi;
					MOV ecx, screenWidth;
					MUL ecx;
					ADD eax, edi;

					XCHG eax, ebx;

					MOV [pixels + ebx], al;

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

	update PROC

		; Bouncing the ball on the walls
		MOV eax, screenHeight;
		DEC eax;

		CMP ballY, eax;
		JE hitY;

		CMP ballY, 1;
		JE hitY;

		JMP doneWalls;

		hitY:
			NEG velY;			
		JMP doneWalls;

		doneWalls:

		; Bouncing ball on player
		MOV eax, ballY;
		DEC eax;

		; Check collision with player 1
		MOV ebx, screenWidth;
		MOV edx, 0;
		MUL ebx;

		ADD eax, playerOffset;

		MOVZX eax, [pixels + eax];

		CMP al, playerPixel;
		JNE notColliding1;

		MOV eax, ballX;
		CMP eax, playerOffset;

		JNE notColliding1;

		CMP velX, 0;
		JG velXPositive;
		NEG velX;

		velXPositive:
		;CALL readInt;

		notColliding1:

		moveBall:
		; Moving the ball
		MOV eax, velX;
		ADD ballX, eax;

		MOV eax, velY;
		ADD ballY, eax;

		ret;
	update ENDP

	main PROC

		CALL initialize;
		MOV ecx, 0;
		gameLoop:

			CALL update;
			CALL renderScreen;
			CALL handleInput;
			CALL dumpRegs;

			MOV eax, 33;

			CALL delay;
			
		LOOP gameLoop;


	main ENDP
	END main