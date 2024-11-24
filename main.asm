INCLUDE irvine32.inc

.data
	; // Screen Info
	screenHeight = 25;
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
	playerWidth = 4;
	
	; // Ball info
	ballx DWORD ?;
	bally DWORD ?;

	velx DWORD 1;
	vely DWORD -1;

	; // Key info
	upKey1 = 57h;
	downKey1 = 53h;
	upKey2 = 26h;
	downKey2 = 28h;
	quitKey = 51h;

	; // Game info
	player1Score DWORD 0;
	player2Score DWORd 0;

	scoreToWin DWORD 3;

	score1Prompt BYTE "Player 1 Score: ", 0;
	score2Prompt BYTE "                                              Player 2 Score: ", 0;

	player1WonPrompt BYTE "                                        PLAYER 1 WON !", 0;
	player2WonPrompt BYTE "                                        PLAYER 2 WON !", 0;

	introductionPrompt BYTE "                  WELCOME TO PONG (Written in x86 Assembly)", 0;
	
	player1Controls BYTE "Player 1:- UP: W DOWN: S", 0;
	player2Controls BYTE "Player 2:- UP: Arrow Up DOWN: Arrow Down", 0;
	otherControls BYTE "Quit: Q", 0;

	ribbon BYTE "========================================================================================", 0;

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

		; Display Scores
		MOV edx, OFFSET score1Prompt;
		CALL writeString;

		MOV eax, player1Score;
		CALL writeDec;

		MOV edx, OFFSET score2Prompt;
		CALL writeString;

		MOV eax, player2Score;
		CALL writeDec;
		CALL crlf;

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
						MOV ebx, player2;
						SUB ebx, playerWidth;

						CMP esi, ebx;
						JLE notPlayer2;

						MOV ebx, player2;
						ADD ebx, playerWidth;

						CMP esi, ebx;
						JGE notPlayer2;


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

		
		; Print Controls
		MOV edx, OFFSET player1Controls;
		CALL writeString;
		CALL crlf;

		MOV edx, OFFSET player2Controls;
		CALL writeString;
		CALL crlf;

		MOV edx, OFFSET otherControls;
		CALL writeString;
		CALL crlf;

		ret;
	renderScreen ENDP

	handleInput PROC

		; Check if ball is coming to player 1 or player 2
		; Then listen for inputs accordingly

		CALL readKey;

		CMP velX, 0;
		JG player2Input;

			CMP dx, upKey1;
			JE player1Up;

			CMP dx, downKey1; 
			JE player1Down;

		JMP playerInputDone;

		player2Input:

			CMP dx, upKey2;
			JE player2Up;

			CMP dx, downKey2;
			JE player2Down;

		playerInputDone:

		CMP dx, quitKey;
		JE quit;

		JMP done;

		player1Up:
			MOV ebx, 0;
			ADD ebx, playerWidth;
			CMP player1, ebx;
			JLE done;

			DEC player1;
		JMP done;

		player1Down:
			MOV ebx, screenHeight;
			DEC ebx;
			SUB ebx, playerWidth;
				
			CMP player1, ebx;
			JGE done;

			INC player1;
		JMP done;

		player2Up:
			MOV ebx, 0;
			ADD ebx, playerWidth;
			CMP player2, ebx;
			JLE done;

			DEC player2;
		JMP done;

		player2Down:
			MOV ebx, screenHeight;
			DEC ebx;
			SUB ebx, playerWidth;
				
			CMP player2, ebx;
			JGE done;

			INC player2;
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

		MOV velY, -1;
		
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
		DEC eax;

		CMP ballY, eax;
		JGE hitBottom;

		CMP ballY, 1;
		JLE hitTop;

		JMP doneWalls;

		hitTop:
			MOV ballY, 1;
			NEG velY;			
		JMP doneWalls;

		hitBottom:
			MOV ballY, screenHeight;
			SUB ballY, 2;
			NEG velY;			
		JMP doneWalls;

		doneWalls:

		; Check collision with player 1
		MOV eax, ballY;

		MOV ebx, screenWidth;
		MOV edx, 0;
		MUL ebx;

		ADD eax, playerOffset;
		
		; Getting the pixel in x axis of player, but y axis of ball
		MOVZX eax, [pixels + eax];

		; If the pixel is not a player, then not colliding
		CMP al, playerPixel;
		JNE notColliding1;

		; If the ball's x axis is one left of the player's, then not colliding
		MOV eax, ballX;
		DEC eax;
		CMP eax, playerOffset;
		JNE notColliding1;

		; Getting the offset of the hit (distance of the hit point to the center of the player)
		MOV eax, ballY;
		SUB eax, player1;

		; Diving the offset by 2
		;MOV ebx, 2;
		;MOV edx, 0;
		;DIV ebx;


		; The resultant is now the vertical velocity
		MOV vely, eax;
		;CALL readInt;


		offsetNotNegative:



		; Changing velocity as a result of the collision.
		NEG velX;

		notColliding1:
			
			; Checking collision with player 2
			MOV eax, ballY;

			MOV ebx, screenWidth;
			MOV edx, 0;
			MUL ebx;

			ADD eax, screenWidth;
			SUB eax, playerOffset;
			DEC eax;
		
			; Getting the pixel in x axis of player, but y axis of ball
			MOVZX eax, [pixels + eax];

			; If the pixel is not a player, then not colliding
			CMP al, playerPixel;
			JNE notColliding2;
			
			; If the ball's x axis is one right of the player's, then not colliding
			MOV eax, ballX;
			INC eax;
			MOV edx, screenWidth;
			SUB edx, playerOffset;
			DEC edx;
			CMP eax, edx;
			JNE notColliding2;

			; Getting the offset of the hit (distance of the hit point to the center of the player)
			MOV eax, ballY;
			SUB eax, player2;

			; Diving the offset by 2
			;MOV ebx, 2;
			;MOV edx, 0;
			;DIV ebx;


			; The resultant is now the vertical velocity
			MOV vely, eax;
			;CALL readInt;

			NEG velX;

			notColliding2:

		moveBall:
		; Moving the ball
		MOV eax, velX;
		ADD ballX, eax;

		MOV eax, velY;
		ADD ballY, eax;

		CALL updateScores;

		ret;
	update ENDP

	updateScores PROC
		
		CMP ballX, 0;
		JL score2;

		CMP ballX, screenWidth - 1;
		JG score1;
		
		JMP noScore;

		score1:
			INC player1Score;
			MOV velX, -1;
			CALL initialize;
		JMP noScore;

		score2:
			INC player2Score;
			MOV velX, 1;
			CALL initialize;
		JMP noScore;

		noScore:
		
		ret;
	updateScores ENDP

	checkGameOver PROC

		MOV eax, player1Score;
		CMP eax, scoreToWin;
		JGE player1Won;

		MOV eax, player2Score;
		CMP eax, scoreToWin;
		JGE player2Won;

		JMP noOneWon;

		player1Won:
			CALL clrscr;

			MOV edx, OFFSET ribbon;
			CALL writeString;
			CALL crlf;

			MOV edx, OFFSET player1WonPrompt;
			CALL writeString;
			CALL crlf;

			MOV edx, OFFSET ribbon;
			CALL writeString;
			CALL crlf;
			
			MOV eax, 2000;
			CALL delay;
			exit;
		JMP noOneWon;

		player2Won:
			CALL clrscr;
			MOV edx, OFFSET player2WonPrompt;
			CALL writeString;

			MOV eax, 1000;
			CALL delay;
			exit;
		JMP noOneWon;

		noOneWon:
		ret;
	checkGameOver ENDP

	introduce PROC
		CALL clrscr;

		MOV edx, OFFSET ribbon;
		CALL writeString;
		CALL crlf;

		MOV edx, OFFSET introductionPrompt;
		CALL writeString;
		CALL crlf;

		MOV edx, OFFSET ribbon;
		CALL writeString;
		CALL crlf;

		MOV eax, 5000;
		CALL delay;

		CALL clrscr;

		ret;
	introduce ENDP

	main PROC
		
		CALL introduce;
		CALL initialize;
		MOV ecx, 0;
		gameLoop:
			
			CALL checkGameOver;
			CALL update;
			CALL renderScreen;
			CALL handleInput;
			
			MOV eax, 33;

			;CALL delay;
			
		LOOP gameLoop;


	main ENDP
	END main