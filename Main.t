/**
 * BBBBBBBBBBBBBBBBB    LLLLLLLLLLL             IIIIIIIIII MMMMMMMM               MMMMMMMM PPPPPPPPPPPPPPPPP           TTTTTTTTTTTTTTTTTTTTTTT      OOOOOOOOO     
 * B::::::::::::::::B   L:::::::::L             I::::::::I M:::::::M             M:::::::M P::::::::::::::::P          T:::::::::::::::::::::T    OO:::::::::OO   
 * B::::::BBBBBB:::::B  L:::::::::L             I::::::::I M::::::::M           M::::::::M P::::::PPPPPP:::::P         T:::::::::::::::::::::T  OO:::::::::::::OO 
 * BB:::::B     B:::::B LL:::::::LL             II::::::II MM::::::::M         M::::::::MM PP:::::P     P:::::P        T:::::TT:::::::TT:::::T O:::::::OOO:::::::O
 *   B::::B     B:::::B   L:::::L                 I::::I     M::::::::M       M::::::::M     P::::P     P:::::P        TTTTTT  T:::::T  TTTTTT O::::::O   O::::::O
 *   B::::B     B:::::B   L:::::L                 I::::I     M:::::::::M     M:::::::::M     P::::P     P:::::P                T:::::T         O:::::O     O:::::O
 *   B::::BBBBBB:::::B    L:::::L                 I::::I     M:::::M::::M   M::::M:::::M     P::::PPPPPP:::::P                 T:::::T         O:::::O     O:::::O
 *   B:::::::::::::BB     L:::::L                 I::::I     M::::M M::::M M::::M M::::M     P:::::::::::::PP                  T:::::T         O:::::O     O:::::O
 *   B::::BBBBBB:::::B    L:::::L                 I::::I     M::::M  M::::M::::M  M::::M     P::::PPPPPPPPP                    T:::::T         O:::::O     O:::::O
 *   B::::B     B:::::B   L:::::L                 I::::I     M::::M   M:::::::M   M::::M     P::::P                            T:::::T         O:::::O     O:::::O
 *   B::::B     B:::::B   L:::::L                 I::::I     M::::M    M:::::M    M::::M     P::::P                            T:::::T         O:::::O     O:::::O
 *   B::::B     B:::::B   L:::::L        LLLLLL   I::::I     M::::M     MMMMM     M::::M     P::::P                            T:::::T         O::::::O   O::::::O
 * BB:::::BBBBBB::::::B LL:::::::LLLLLLLL:::::L II::::::II MM::::::MM           MM::::::MM PP::::::PP                        TT:::::::TT       O:::::::OOO:::::::O
 * B:::::::::::::::::B  L:::::::::::::::::::::L I::::::::I M::::::::M           M::::::::M P::::::::P           ......       T:::::::::T        OO:::::::::::::OO 
 * B::::::::::::::::B   L:::::::::::::::::::::L I::::::::I M::::::::M           M::::::::M P::::::::P           .::::.       T:::::::::T          OO:::::::::OO   
 * BBBBBBBBBBBBBBBBB    LLLLLLLLLLLLLLLLLLLLLLL IIIIIIIIII MMMMMMMMMM           MMMMMMMMMM PPPPPPPPPP           ......       TTTTTTTTTTT            OOOOOOOOO     
 *
 * Blimp.to --- shoot down the runaway blimps!
 * Copyright (C) 2016 Terry Chen
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * v1.0.0 2016-06-15
 */

% Import shared libraries
import JSON in "lib/shared/JSON.tu",
    CommonBtn in "lib/shared/CommonBtn.tu"

% Set the properties of the main game window
View.Set ("graphics:1280;720,nocursor,nobuttonbar,title:Blimp.to")

% Include module libraries
include "lib/modules/constants.tu"
include "lib/modules/runtime.tu"
include "lib/modules/objectClass.tu"
include "lib/modules/canvasClass.tu"

% Include game modules
include "IntroScreen.t"
include "MainGame.t"

% Exit with error if the screen is not big enough

begin
var tempWindow : int := Window.Open ("graphics:max;max,nobuttonbar")
if maxx >= 1280 and maxy >= 720 then
    Window.Close (tempWindow)
else
    fontDraw ("Error! Screen size less than 1280x720", maxx div 2, maxy div 2 + 20, FONT_TITLE, SPECIAL_FG)
    fontDraw ("Your current screen size: " + intstr (maxx) + "x" + intstr (maxy), maxx div 2, maxy div 2 - 10, FONT_BTN, SPECIAL_FG)
    Error.Halt ("Error! Screen size less than 1280x720")
end if
end


loop
    % @var numLevels The number of levels that have been defined
    % @var numFields The number of data fields in a level file
    var *numLevels : int := 0
    var *numFields : int := 0
    
    % Draw the intro screen
    Intro.drawIntro
    
    exit when stop
    
    % Initialize and play the game
    Game.initLevels (numLevels, numFields)
    
    var data : array 1 .. numLevels, 1 .. numFields, 1 .. 2 of string
    var scores : array 1 .. numLevels of JSON.Pair
    
    Game.initLevelData (data)
    Game.initScores (scores)
    Game.playGame (data, scores)
    Game.saveScores (scores)

    circleWipe (DEFAULT_BG)
end loop

% Cleanup and exit

playMusicStop

Pic.Free (bgPic)

for p : 1 .. upper (plus1000Frames)
    Pic.Free (plus1000Frames (p))
end for

circleWipe (DEFAULT_FG)

fontDraw ("CLOSE WINDOW TO EXIT", maxx div 2, maxy div 2, FONT_TITLE, ACCENT_BG)
