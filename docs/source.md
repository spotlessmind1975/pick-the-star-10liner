# SOURCE CODE (EXPLAINED)

Below you will find the source code of the game explained. The plain file can be read [here](../pick-the-star-10liner-plain.bas). The source code has been written extensively (without abbreviations), in order to make it easier to understand. Each line has been commented to illustrate how the code works.

## INITIALIZATION (LINES 0-1)

    0 DEFINE SCREEN MODE UNIQUE

This is a specific command of the  [ugBasic](https://ugbasic.iwashere.eu) language. The purpose is to ask the  [ugBasic](https://ugbasic.iwashere.eu) compiler to reduce code space by stripping out all that assembly code for graphics modes that won't be used. This command is very useful when you are certain that you are using just only one graphic mode. This command has nothing to do directly with the game algorithm.

    DEFINE STRING COUNT 32
    DEFINE STRING SPACE 512 

These instructions are specific to [ugBasic](https://ugbasic.iwashere.eu), and they are intended to specify the actual space available to strings. The need to indicate this space depends on the fact that the rules oblige the program listing. It follows that, since the runtime module of [ugBasic](https://ugbasic.iwashere.eu) treats the source code like a "string", it is necessary to allocate an adequate amount of space for all computers in order to print it.

    BITMAP ENABLE(16)

We ask for a resolution that gives a good number of colors. Let us remember that [ugBasic](https://ugbasic.iwashere.eu) is an isomorphic language. This means that it is not advisable to indicate a specific resolution or color or other characteristics for the graphics you want, but it is given the opportunity to suggest it. Each compiler will decide, according to the limits of hardware, what resolution and color depth of use.

    CONST a0 = SCREEN WIDTH / 16

Now we calculate the number of stars that will be drawn. This type of calculations is carried out through the use of the constants (`CONST`) which, in general, allow a better performance and an employment of space equal to zero. See [game state](./game-state.md#the-number-of-objects-a0) for more information.

    DEFINE TASK COUNT a0

These instructions are specific to [ugBasic](https://ugbasic.iwashere.eu), and they are intended to specify the actual space available to multitasking. Each task will occupy a specific space, and this command will allocate enough tasks to have one task for each star. See [game state](./game-state.md#the-number-of-objects-a0) for more information.

    DIM y AS POSITION(a0),

This variable maintains the vertical position of each each object that is going to fall down. As there are a number of different objects, the information must be kept in an array, where the position is equal to the number of the task. See [game state](./game-state.md#the-position-of-the-objects-y) for more information.

    t AS THREAD(a0),

This variable maintains the current identifier (handle) for the thread. As there are a number of different objects that moves in parallel, the information must be kept in an array, where the position is equal to the number of the task. See [game state](./game-state.md#multitasking-t) for more information.
    
    p AS BYTE(a0)

This variable maintains the latency in starting of each object that is going to fall down. As there are a number of different objects, the information must be kept in an array, where the position is equal to the number of tasks to be executed in parallel. See [game state](./game-state.md#the-latency-of-objects-p) for more information.

    DIM q AS BYTE(a0)

This variable maintains the kind of object that is going to fall. If it is 0, it is star; otherwise, is a circle. As there are a number of different objects, the information must be kept in an array, where the position is equal to the number of task. See [game state](./game-state.md#the-kind-of-objects-q) for more information.

    DIM a1 AS POSITION, cx AS POSITION, cy AS POSITION

These variables hold the current position of the container. As for the horizontal position, both its current and previous positions are maintained. See [game state](./game-state.md#moving-the-container-a1-cx-cy-a6) for more information.

    DIM a2 AS WORD, a3 AS WORD,

These variables keep the score and penalty in the game, respectively. See [game state](./game-state.md#scoring-a2-a3-a7) for more information.

    a4 AS BYTE, a42 AS BYTE

These variables maintain the remaining game time, in terms of stars and cycles for each star. See [game state](./game-state.md#measuring-the-time-a4-a42) for more information.

    DIM i AS BYTE

This variable is used as an index.

    a6 AS POSITION,

This variables hold the speed of the container. See [game state](./game-state.md#moving-the-container-a1-cx-cy-a6) for more information.

    a7 AS WORD

These variables keep the maximum score in the game. See [game state](./game-state.md#scoring-a2-a3-a7) for more information.

    1 a8 := NEW IMAGE(16,16) : b9 := NEW IMAGE(8,8)
      b0 := NEW IMAGE(8,8) : b1 := NEW IMAGE(8,8)
      b2 := NEW IMAGE(32,8) : bb2 := NEW IMAGE(32,8)

The purpose of these instructions is to allocate a series of graphic surfaces, which will be used to store the various graphical elements of the game.

## SOME NEEDED PROCEDURES (LINES 1-2)

    GLOBAL b0, y, t, b9, p, cx, a2, a3, a4, q, b1, a6, a7

This statement implies that a number of variables will also be accessible within procedures. For a clearer explanation, refer to [the ugBASIC user manual chapter](https://retroprogramming.iwashere.eu/ugbasic:user:procedures#local_and_global_variables).

    PROCEDURE b4
        INK WHITE
        HOME : PRINT "SCORE ";
        LOCATE 6,0 : PRINT "    ";
        LOCATE 6,0 : PRINT a2;
    END PROC

This procedure allows to print the score gained up to this moment. Writing the score erases the previous score. In this way, every time this procedure is called, the score will be updated. See [game state](./game-state.md#scoring-a2-a3-a7) for more information.

    PROCEDURE b5
        INK WHITE
      2    LOCATE COLUMNS - 7,0: PRINT "  ";STRING("*",(a4\4));STRING(" ",(5-(a4/4)))
    END PROC

This procedure prints the remaining game time, in terms of stars. Each time it is called up, the screen time is updated, erasing the previous time. See [game state](./game-state.md#measuring-the-time-a4-a42) for more information.

    PROCEDURE b6
        INK WHITE
        LOCATE COLUMNS - 7,0:  PRINT "HI ";a7
    END PROC

This procedure allows to print the maximum score (hiscore) gained up to this moment. Writing the hiscore erases the previous hiscore, and the time, as well. In this way, every time this procedure is called, the hiscore will be updated. See [game state](./game-state.md#scoring-a2-a3-a7) for more information.

## THE FALLING OBJECT BEHAVIOUR (LINES 2-4)

    PARALLEL PROCEDURE b0Move

From this point on we define a parallel procedure. Parallel procedures are procedures that are executed in multitasking mode, i.e. if a certain number of these procedures are launched, each one will be executed simulantemente to the others. With this procedure we can therefore describe the behavior of each single object that falls. See [game state](./game-state.md#multitasking-t) for more information.

        DO

The procedure is, to all intents and purposes, a repeat of a basic cycle, starting here.

            [p] = 100+RND(42)
            [q] = [p] AND 1
            WAIT [p] CYCLES PARALLEL

First we define the type of falling object and after how much latency time it will have to start falling. So the cycle will start by waiting for the latency time first.

        LOCATE TASK*2,ROWS/2:PRINT "    "

Before starting the fall, we erase any score (positive or negative) printed and referred to this falling object.

        [y] = 8 + RND(3)

We establish from what height to start the fall.

        WHILE [y] < ( SCREEN HEIGHT - 32 )
            INC [y] 
          3 INC [y]
            PUT IMAGE b9 AT TASK*16,[y]-2
            IF [q] > 0 THEN
                PUT IMAGE b1 AT TASK*16,[y]
            ELSE
                PUT IMAGE b0 AT TASK*16,[y]
            ENDIF
            YIELD
        WEND

This loop just simulates the object falling. We start from the assigned vertical position and increase it, repeating the cycle until we reach the low wall. We move down two pixels at a time, each time erasing the drawn object in the old position and redrawing it in the new one. At each turn, we call the appropriate instruction to signal to the environment that, if desired, it is possible to perform other tasks (YIELD).

        PUT IMAGE b9 AT TASK*16,[y]

Finally we delete the last drawn object.

        IF (((TASK*16) > cx ) AND ((( TASK*16)+8) < cx+32 ) ) THEN

Since the object has almost reached the ground, it is checked whether it ended up inside or outside the container. To understand this we use the relative position of the container with respect to the object.

            c8 = 5 + (1-[q])*10
            a2 = a2 + c8

If it lands inside the container, we add the score to that accumulated by the player (5 points for the circle, 15 points for the star).

            a6 = 1+[q]*3

At this point we update the speed at which the container will have to move, based on which object we have collected.

            INK WHITE : LOCATE TASK*2,ROWS/2:PRINT "+";c8

We show the score on the screen.

          4 ELSE
                INC a3
                IF a3 > 8 THEN
                    INK RED : LOCATE TASK*2,ROWS/2:PRINT "-30"
                    IF a2 > 29 THEN
                        a2 = a2 - 30
                    ENDIF
                    a3 = 0
                ENDIF
            ENDIF

If the object fell outside the container, we add a penalty. If the limit of eight dropped objects is exceeded (that is, if a penalty of 8 is reached), the score will be deducted by thirty points. This will also be shown on the screen, as a penalty for the dropped object.

            b4[]
        LOOP
    END PROC

We update the score, and here ends the loop for this falling object.

## THE GRAPHICAL PREPARATION (LINES 4-5)

    CLS BLACK : INK WHITE
    HOME : INK RED : PRINT "o"
    GET IMAGE b1 FROM 0,0

With these instructions you start drawing the elements of the game. First the circle is drawn, taking advantage of the fact that the letter "o" is already present within the system, as a letter.

    HOME : INK WHITE : PRINT "*"
    GET IMAGE b0 FROM 0,0

Then draw the star.

    CLS : GET IMAGE b9 FROM 0,0 : GET IMAGE bb2 FROM 0,0

At this point we clear the screen and acquire two empty boxes, which we will use to speed up the cancellation of the container and the various falling objects.

      INK BROWN
      BAR 0,0 TO 5,2
    5 BAR 7,0 TO 10,2 : BAR 12,0 TO 15,2 : BAR 0,4 TO 1,6
      BAR 3,4 TO 12,6 : BAR 14,4 TO 15,6 : BAR 0,8 TO 5,10
      BAR 7,8 TO 14,10 : BAR 0,12 TO 1,14 : BAR 3,12 TO 9,14
      BAR 11,12 TO 15,14 
      GET IMAGE a8 FROM 0,0

Now we can draw the low wall. The shape is such as to allow the various elements to be juxtaposed so as to form a continuous low wall.

      CLS
      INK YELLOW
      BAR 0,0 TO 8,8
      BAR 0,4 TO 31,8
      BAR 24,0 TO 31,8
      GET IMAGE b2 FROM 0,0

Finally, let's draw the container.

## THE OUTER LOOP (LINES 5-9)

      DO

This is where the main loop of the game begins.

    6 FOR i = 0 TO a0-1 : t(i) = HALTED SPAWN b0Move : NEXT

First, we start a series of parallel tasks equal to the number of falling objects. The tasks are prepared but remain in a waiting state, so that they will start when the game actually starts.

    CLS

Clear the screen.

    a2 = 0 : a6 = 1 : a42 = 0 : a4 = 20
    cx = ( SCREEN WIDTH - 32 ) / 2 : a1 = cx - 1

We initialize the various variables of the program.

    FOR i = 0 TO ((SCREEN WIDTH / 16)-1)
        PUT IMAGE a8 AT (i*16),(SCREEN HEIGHT - 16)
    NEXT

Let's draw the wall.

    b4[] : b6[]

We print the current score and the maximum score.

      LOCATE , ROWS / 2 - 2
      CENTER "PICK THE STAR"
      CENTER "(10 LINER)"
      LOCATE , ROWS / 2 + 2
    7 CENTER "PRESS ANY KEY"
      WAIT KEY RELEASE

We print the title of the game, and wait for a key to be pressed (and released).

    RANDOMIZE TIMER 

Let's make the game more random with the appropriate instruction, which initializes the generator based on non-deterministic elements (it's especially useful for emulators).

    FOR i = 0 TO a0-1 : RESPAWN t(i) : NEXT

Start the series of parallel tasks.

    LOCATE , ROWS / 2 - 2
    CENTER "             "
    CENTER "             "
    LOCATE , ROWS / 2 + 2
    CENTER "             "

Clear the title of the game.

    b5[]

We print the remaining time.

## THE INNER LOOP (LINES 7-8)

    BEGIN GAMELOOP

This is the internal loop of the game.

          cx = cx + ( (JLEFT(0)>0) - (JRIGHT(0)>0) ) * a6
          IF cx < 0 THEN
              cx = 0
          ENDIF
          IF cx > (SCREEN WIDTH - 32) THEN
        8     cx = SCREEN WIDTH - 32
          ENDIF

We update the position of the container based on the value found on the joystick: if the joystick is moved to the left, the container will move to the left, and vice versa. Clearly, we cannot move the container beyond the limits of the playing field.

        IF a1 <> cx THEN
            WAIT VBL
            PUT IMAGE bb2 AT a1,SCREEN HEIGHT - 16 - 8
            PUT IMAGE b2 AT cx,SCREEN HEIGHT - 16 - 8
            a1 = cx
        ELSE
            WAIT VBL
        ENDIF    

Where there has been an effective change to the position of the container, it will be deleted from the old position and drawn in the new one. In one case or another it is possible to wait for the vertical blank, which guarantees that the operation is carried out without flickering.

        INC a42
        IF a42 = 255 THEN
            DEC a4
            a42 = 0
            b5[]
        ENDIF
        EXIT IF a4 = 0

At this point we can decrease the elapsed time, possibly updating the drawn stars. Moreover, if the time arrivers to zero, we must exit the internal loop.

    END GAMELOOP

Here the internal game loop ends.

## THE FINAL STEPS (LINES 8-9)

    FOR i = 0 TO a0-1 : KILL t(i) : NEXT

Stop the tasks.

    CLS     
    IF a2 > a7 THEN
        a7 = a2
    ENDIF

Update the high score.

      LOCATE , ROWS / 2
    9 CENTER "GAME OVER"

Print the game over message.

      b4[] : b6[]

Update the score and high score.

      WAIT KEY RELEASE

Wait the press (and release) of a key.

    LOOP

Repeat the outermost loop.