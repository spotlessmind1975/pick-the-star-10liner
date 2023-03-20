0

DEFINE SCREEN MODE UNIQUE
DEFINE STRING COUNT 32
DEFINE STRING SPACE 512 

BITMAP ENABLE(16)

CONST a0 = SCREEN WIDTH / 16

DEFINE TASK COUNT a0

DIM y AS POSITION(a0), t AS THREAD(a0), p AS BYTE(a0)
DIM q AS BYTE(a0)

DIM a1 AS POSITION, cx AS POSITION, cy AS POSITION
DIM a2 AS WORD, a3 AS WORD, a4 AS BYTE, a42 AS BYTE
DIM i AS BYTE, a6 AS POSITION, a7 AS WORD

1

a8 := NEW IMAGE(16,16)
b9 := NEW IMAGE(8,8)
b0 := NEW IMAGE(8,8)
b1 := NEW IMAGE(8,8)
b2 := NEW IMAGE(32,8)
bb2 := NEW IMAGE(32,8)

GLOBAL b0, y, t, b9, p, cx, a2, a3, a4, q, b1, a6, a7

PROCEDURE b4

	INK WHITE
	HOME: PRINT "SCORE ";
	LOCATE 6,0: PRINT "    ";
	LOCATE 6,0: PRINT a2;

END PROC

PROCEDURE b5

	INK WHITE
	
2
	
	LOCATE COLUMNS - 7,0: PRINT "  ";STRING("*",(a4\4));STRING(" ",(5-(a4/4)))

END PROC

PROCEDURE b6

	INK WHITE
	LOCATE COLUMNS - 7,0:  PRINT "HI ";a7

END PROC

PARALLEL PROCEDURE b0Move
	DO
		[p] = 100+RND(42)
		[q] = [p] AND 1
		WAIT [p] CYCLES PARALLEL
		LOCATE TASK*2,ROWS/2:PRINT "    "
		[y] = 8 + RND(3)
		WHILE [y] < ( SCREEN HEIGHT - 32 )
			INC [y] 

3
			
			INC [y]
			PUT IMAGE b9 AT TASK*16,[y]-2
			IF [q] > 0 THEN
				PUT IMAGE b1 AT TASK*16,[y]
			ELSE
				PUT IMAGE b0 AT TASK*16,[y]
			ENDIF
			YIELD
		WEND
		PUT IMAGE b9 AT TASK*16,[y]
		IF (((TASK*16) > cx ) AND ((( TASK*16)+8) < cx+32 ) ) THEN
			c8 = 5 + (1-[q])*10
			a2 = a2 + c8
			a6 = 1+[q]*3
			INK WHITE
			LOCATE TASK*2,ROWS/2:PRINT "+";c8

4
		
		ELSE
			INC a3
			IF a3 > 8 THEN
				INK RED
				LOCATE TASK*2,ROWS/2:PRINT "-1"
				IF a2 > 29 THEN
					a2 = a2 - 30
				ENDIF
				a3 = 0
			ENDIF
		ENDIF
		b4[]
	LOOP
END PROC

CLS BLACK
INK WHITE

HOME:INK RED:PRINT "o"

GET IMAGE b1 FROM 0,0

HOME:INK WHITE:PRINT "*"

GET IMAGE b0 FROM 0,0

CLS

GET IMAGE b9 FROM 0,0
GET IMAGE bb2 FROM 0,0

INK BROWN

BAR 0,0 TO 5,2

5

BAR 7,0 TO 10,2
BAR 12,0 TO 15,2
BAR 0,4 TO 1,6
BAR 3,4 TO 12,6
BAR 14,4 TO 15,6
BAR 0,8 TO 5,10
BAR 7,8 TO 14,10
BAR 0,12 TO 1,14
BAR 3,12 TO 9,14
BAR 11,12 TO 15,14

GET IMAGE a8 FROM 0,0

CLS 

INK YELLOW

BAR 0,0 TO 8,8
BAR 0,4 TO 31,8
BAR 24,0 TO 31,8

GET IMAGE b2 FROM 0,0

DO

6

	FOR i = 0 TO a0-1
		t(i) = HALTED SPAWN b0Move 
	NEXT
	
	CLS

	a2 = 0
	a6 = 1
	a42 = 0
	a4 = 20
	cx = ( SCREEN WIDTH - 32 ) / 2
	a1 = cx - 1

	FOR i = 0 TO ((SCREEN WIDTH / 16)-1)
		PUT IMAGE a8 AT (i*16),(SCREEN HEIGHT - 16)
	NEXT
	
	b4[]
	b6[]

	LOCATE , ROWS / 2 - 2
	CENTER "PICK THE STAR"
	CENTER "(10 LINER)"
	LOCATE , ROWS / 2 + 2
	
7
	
	CENTER "PRESS ANY KEY"
	
	WAIT KEY RELEASE

	RANDOMIZE TIMER
	
	FOR i = 0 TO a0-1
		RESPAWN t(i)
	NEXT

	LOCATE , ROWS / 2 - 2
	CENTER "             "
	CENTER "             "
	LOCATE , ROWS / 2 + 2
	CENTER "             "

	b5[]

	BEGIN GAMELOOP
	
		cx = cx + ( (JLEFT(0)>0) - (JRIGHT(0)>0) ) * a6
		
		IF cx < 0 THEN
			cx = 0
		ENDIF
		
		IF cx > (SCREEN WIDTH - 32) THEN
		
		8
		
			cx = SCREEN WIDTH - 32
		ENDIF
	
		IF a1 <> cx THEN
			WAIT VBL
			PUT IMAGE bb2 AT a1,SCREEN HEIGHT - 16 - 8
			PUT IMAGE b2 AT cx,SCREEN HEIGHT - 16 - 8
			a1 = cx
		ELSE
			WAIT VBL
		ENDIF	
	
		INC a42
		IF a42 = 255 THEN
			DEC a4
			a42 = 0
			b5[]
		ENDIF
		
		EXIT IF a4 = 0
		
	END GAMELOOP
	
	FOR i = 0 TO a0-1
		KILL t(i)
	NEXT
	
	CLS
	
	IF a2 > a7 THEN
		a7 = a2
	ENDIF
	
	LOCATE , ROWS / 2
	
9

	CENTER "GAME OVER"
	b4[]
	b6[]
	
	WAIT KEY RELEASE

LOOP

