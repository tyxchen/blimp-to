/**
 * Tutorial.t --- plays the tutorial (a series of images) for Blimp.to
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
 */

fork playMusicLoop ("Bassa Island.mp3")

begin
var tutorialGif : array 1 .. Pic.Frames (FOLDER_IMAGES + "tutorial.gif") of int
var delayTime : int
var nextBtn : CommonBtn.Btn

circleWipe (DEFAULT_BG)

% Initialize a series of images to use for the tutorial
Pic.FileNewFrames (FOLDER_IMAGES + "tutorial.gif", tutorialGif, delayTime)
CommonBtn.initBtn (nextBtn, "NEXT", maxx - 150 - DEFAULT_PADDING, DEFAULT_BOX_HEIGHT + DEFAULT_PADDING, 150, 36, ACCENT_BG, ACCENT_FG, FONT_BTN, false)

% Loop through the images in the tutorial
for i : 1 .. upper (tutorialGif)
    var ch : string (1)
    
    Pic.Draw (tutorialGif (i), 0, 0, picCopy)

    % Change text if the image displayed is the last one
    if i = upper (tutorialGif) then
        nextBtn.text := "EXIT"
    end if

    CommonBtn.selectBtn (nextBtn)
    
    % Only continue to next step when the user presses enter or space
    loop
        getch (ch)
        
        exit when ch = KEY_ENTER or ch = ' '
    end loop
    
    Pic.Free (tutorialGif (i))
end for
end

circleWipe (DEFAULT_BG)

playMusicStop