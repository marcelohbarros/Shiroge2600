    rem Screen settings
    set tv ntsc
    set romsize 4k
    set kernel_options pfcolors no_blank_line background

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

    pfcolors:
    0
    176
    176
    242
    242
    242
    112
    112
    210
    210
    176
    0
    0
end

    const BLACK = 0
    const GRAY = 7
    const RED = 67
    const WHITE = 15
    const GREEN = 198
    const ZERO_LIFE_COUNT = 0
    const ONE_LIFE_COUNT = 128
    const TWO_LIFE_COUNT = 160
    const THREE_LIFE_COUNT = 168
    const END_LEVEL = 137
    const BOTTOM_LEVEL = 85

    rem Background color
    COLUBK = BLACK

    const pfscore = 1

    rem Player and score color
    scorecolor = GRAY
    pfscorecolor = RED
 
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
    
    dim level = score + 2

menu
    playfield:
................................
................................
.XXX..XX.XXXXXXX..XX...X.X......
...XX.XX.XX...XX.XXXXXXXX.......
.XX...XX.XX...XX.X..XX...XXXXXX.
..XX.XX..XX...XX....XX..........
....XX...XXXXXXX...XX...........
..XXX....XX...XX.XXX............
................................
................................
end
    player0x = 0
    player0y = 0
    level = 0

    if joy0fire then goto level1 else goto draw
    goto menu

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
    level = 1

    goto startstage
 
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
    level = 2

    goto startstage

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
    level = 3

    goto startstage

startstage
    vel = 128
    direction{0} = 1
    jumped = 1
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

    if ynext >= BOTTOM_LEVEL then goto lostlife

    rem draw life bar
    if life = 3 then pfscore1 = THREE_LIFE_COUNT
    if life = 2 then pfscore1 = TWO_LIFE_COUNT
    if life = 1 then pfscore1 = ONE_LIFE_COUNT
    if life = 0 then pfscore1 = ZERO_LIFE_COUNT

    rem Updating position
    player0x = xnext
    player0y = ynext

    if player0x > END_LEVEL then goto nextlevel

    rem Draw screen and setup screen registers 
draw
    rem Reflect sprite
    if direction{0} then REFP0 = 8

    rem Player color
    COLUP0 = 252
 
    rem Playfield color
    COLUPF = 240
    
    PF0 = 255

    drawscreen
    if level = 0 then goto menu else goto main

lostlife
    if life = 0 then goto gameover
    life = life - 1
    on level goto menu level1 level2 level3

nextlevel
    level = level + 1
    on level goto menu level1 level2 level3 gameover

gameover
    life = 3
    if joy0fire then goto menu 
    goto gameover
