    rem Screen settings
    set tv ntsc
    set romsize 4k

    rem Player sprite
    player0:
    %11101111
    %01100110
    %10011001
    %10000001
    %01010010
    %00101100
    %01010111
    %00111101
end

    rem Background color
    COLUBK = 0

    const pfscore=1

    rem Player and score color
    scorecolor = 7
    pfscorecolor = 67
 
    rem Direction player is looking
    dim direction = d

    rem Next frame position
    dim xnext = x
    xnext = player0x
    dim ynext = y
    ynext = player0y

    rem Position in playfield grid
    dim tilex = t
    dim tiley = u
    rem Conversion for player to playfield coordinates
    tilex = (xnext - 13) / 4
    tiley = ynext / 8

    rem Vertical velocity: 128 is stopped
    dim vel = v

    dim counter = c
    counter = 0

    dim jumped = j
    jumped = 0
 
    dim life = l
    life = 3

    dim level = m
    level = 1

    rem Run every time a life is lost
level1
    playfield:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X..........XX..................X
X..........XX..................X
X..........XX..................X
XXXXXX.....XX.......XX.........X
X........XXXX......XX..........X
X..............................X
X..............XX..............X
X..............XX..............X
X....XXX......XXX...............
XXXXXXX....XXXXXX.......XXXXXXXX
end

    rem Initial position and speed
    player0x = 25
    player0y = 24
    vel = 128
    direction{0} = 1
    jumped{0} = 1
    score = 1

    goto main
 
level2
    playfield:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X..............................X
X..............................X
X..............................X
X..XX......XX..................X
X...XX.........................X
X..............................X
X..............................X
X..............................X
X...................XX..........
X..........................XXXXX
end

    rem Initial position and speed
    player0x = 25
    player0y = 25
    vel = 128
    direction{0} = 1
    jumped = 1
    score = 2

    goto main

level3
    playfield:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X.................X............X
X.................X............X
X.................X............X
XXXXX.............X............X
X...X......XX..................X
X.......................XXXXX..X
X..............................X
X..............................X
X...............................
X.............................XX
end

    rem Initial position and speed
    player0x = 25
    player0y = 25
    vel = 128
    direction{0} = 1
    jumped = 1
    score = 3

    goto main

    rem Main routine
main
    if switchreset then reboot

    rem Buffers for player position in next frame
    xnext = player0x
    ynext = player0y

    rem Increase vel for each 8 frames
    counter = counter + 1
    if counter{0} && counter{1} && counter{2} then vel = vel + 1

    rem Left movement
    if joy0left then xnext = xnext - 1 : direction{0} = 0
    tilex = (xnext - 13) / 4 - 1
    if pfread(tilex, tiley) then xnext = player0x

    rem Right movement
    if joy0right then xnext = xnext + 1 : direction{0} = 1
    tilex = (xnext - 14) / 4 + 1
    if pfread(tilex, tiley) then xnext = player0x

    rem Vertical movement
    if joy0up && !jumped{0} then vel = 126 : jumped{0} = 1
    ynext = ynext + vel - 128
    tilex = (xnext - 13) / 4
    tiley = (ynext - 1) / 8
    if pfread(tilex, tiley) then ynext = player0y : vel = 128 : jumped{0} = 0
    tilex = tilex - 1
    if pfread(tilex, tiley) then ynext = player0y : vel = 128 : jumped{0} = 0
    tilex = (xnext - 14) / 4 + 1
    if pfread(tilex, tiley) then ynext = player0y : vel = 128 : jumped{0} = 0

    if ynext >= 85 then goto lostlive

    rem draw life bar
    if life = 3 then pfscore1 = 168
    if life = 2 then pfscore1 = 160
    if life = 1 then pfscore1 = 128
    if life = 0 then pfscore1 = 0

    rem Updating position
    player0x = xnext
    player0y = ynext

    if player0x > 137 goto nextlevel

    rem Draw screen and setup screen registers 
draw
    rem Reflect sprite
    if direction{0} then REFP0 = 8

    rem Player color
    COLUP0 = 15
 
    rem Playfield color
    COLUPF = 198

    drawscreen
    goto main

lostlive
    if life = 0 then goto gameover
    life = life - 1
    if level = 1 then goto level1
    if level = 2 then goto level2
    if level = 3 then goto level3

nextlevel
    level = level + 1
    if level = 1 then goto level1
    if level = 2 then goto level2
    if level = 3 then goto level3

gameover
    life = 3
    if joy0fire then goto level1
    goto gameover
