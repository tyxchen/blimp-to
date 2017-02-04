/**
 * runtime.tu --- Contains variables to be initialized at compile-time
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

/** '+1000' SPRITE **/

% @const FRAMES_PLUS1000 The number of frames in the '+1000' sprite
% @var plus1000Frames An array to store the frames of the '+1000' sprite
const *FRAMES_PLUS1000 : int := Pic.Frames (FOLDER_IMAGES + SPRITE_PLUS1000)
var *plus1000Frames : array 1 .. FRAMES_PLUS1000 of int

% Initialize the `plus1000Frames` array
% This is done in a block to restrict the scope of the dummy variable `delayTime`
begin
var delayTime : int

Pic.FileNewFrames (FOLDER_IMAGES + SPRITE_PLUS1000, plus1000Frames, delayTime)
end

/** BACKGROUND IMAGE **/

% @var bgPic The background that forms the game
const *bgPic : int := Pic.FileNew (FOLDER_IMAGES + "sky.jpg")

/** GENERAL RUNTIME GLOBALS **/

% @var stop Whether to stop the game or not
var *stop : boolean := false

% @var stopMusic Stop any currently playing music
var *stopMusic : boolean := false

% @var settings Settings that we start with. Hardcoded bounds because there doesn't exist a way to
%               dynamically figure out those bounds
var *settings : array 1 .. 2 of JSON.Pair

% Read game settings from a JSON file
proc *initSettings
    % @var settingsFile Stream identifier for the settings file
    % @var settingsData Temporary string containing the contents of the settings file
    var settingsFile : int
    var settingsData : string := ""

    open : settingsFile, FOLDER_DATA + "settings.json", get

    % Read entirety of settings file into settingsData
    loop
        var line : string
        
        exit when eof (settingsFile)
        
        get : settingsFile, line : *
        
        settingsData += line
    end loop
    
    % Populate settings array
    JSON.toArray (settingsData, settings)
    
    close : settingsFile
end initSettings

% Save game settings to the JSON file
proc *saveSettings
    % @var settingsFile Stream identifier for the settings file
    % @var settingsData Temporary string of the stringified array
    var settingsFile : int
    var settingsData : string
    
    open : settingsFile, FOLDER_DATA + "settings.json", put
    
    % Stringify array into valid JSON
    JSON.fromArray (settings, settingsData)
    
    put : settingsFile, settingsData
    
    close : settingsFile
end saveSettings

% Output debug information into a debug file, or the screen
%
% @param s The debug message to write
proc *BJON_DEBUG (s : string)
    #if false then
    var f : int
    open : f, "debug.txt", seek, mod, put
    seek : f, *
    put : f, s ..
    close : f
    #else
    put s ..
    #end if
end BJON_DEBUG

% Format seconds into a human-readable string
%
% @param seconds The number of seconds to format
%
% @result A string in the form mm:ss
fcn *fmtSeconds (seconds : int) : string
    var m : int := seconds div 60
    var s : int := seconds mod 60
    var builder : string := ""
    
    if m < 10 then
        builder += "0" + intstr (m)
    else
        builder += intstr (m)
    end if
    
    builder += ":"
    
    if s < 10 then
        builder += "0" + intstr (s)
    else
        builder += intstr (s)
    end if
    
    result builder
end fmtSeconds

% Play a tone of music only if allowed by user
%
% @param music The name of the file to play
process *playMusic (music : string)
    if settings (2).value = "on" then
        Music.PlayFile (FOLDER_MUSICS + music)
    end if
end playMusic

% Play a song in a background loop only if allowed by user
%
% @param music The name of the file to play
process *playMusicLoop (music : string)
    stopMusic := false
    
    if settings (2).value = "on" then
        Music.PlayFileLoop (FOLDER_MUSICS + music)
        
        % Check for command to stop music
        loop
            if stopMusic then
                Music.PlayFileStop
                exit
            end if
        end loop
    end if
end playMusicLoop

% Stop any music currently being played by (1) setting stopMusic to true for background, and
% (2) playing a .wav file to stop game tones as they are being played
proc *playMusicStop
    stopMusic := true
    Music.PlayFileReturn (FOLDER_MUSICS + "stop.wav")
end playMusicStop

% Display text centred at the given coordinates
%
% @param str The text to display
% @param x The x-coordinate to display the text at
% @param y The y-coordinate to display the text at
% @param font The ID of the font to write the text in
% @param clr The colour to write the text in
proc *fontDraw (str : string, x : int, y : int, font : int, clr : int)
    % @var h The height of the font
    % @var ascent The ascent of the font
    % @var descent The descent of the font
    % @var i The internal leading of the 's font
    var h : int
    var ascent : int
    var descent : int
    var i : int

    % Get the various values defined above for the font, so that the text can be centred in
    % the button
    Font.Sizes (font, h, ascent, descent, i)

    Font.Draw (str, x - Font.Width (str, font) div 2, y - (ascent - descent) div 2, font, clr)
end fontDraw

% Update the text in a databox
%
% @param l The label of the databox
% @param s The text to display
% @param x The x-coordinate of the lower-left corner of the databox
% @param y The y-coordinate of the lower-left corner of the databox
proc *updateBox (l : string, s : string, x : int, y : int)
    Draw.FillBox (x, y, x + DEFAULT_BOX_WIDTH, y + DEFAULT_BOX_HEIGHT, DEFAULT_BG)
    fontDraw (l, x + DEFAULT_BOX_WIDTH div 2, y + DEFAULT_BOX_HEIGHT div 2 + 10, FONT_BOX_LABEL, DEFAULT_FG)
    fontDraw (s, x + DEFAULT_BOX_WIDTH div 2, y + DEFAULT_BOX_HEIGHT div 2 - 5, FONT_BOX, DEFAULT_FG)
end updateBox

% Display an incremented score as a HUD onscreen
%
% @param x The x-coordinate to start the score at
% @param y The y-coordinate to start the score at
process *hudIncScore (x : int, y : int)
    % @var frame An individual frame of the sprite
    var frame : int

    % Initialize sprite
    frame := Sprite.New (plus1000Frames (1))
    Sprite.SetPosition (frame, x - Pic.Width (plus1000Frames (1)), y, false)
    Sprite.SetHeight (frame, INFTY)
    Sprite.Show (frame)

    % Display next frames of the sprite - start at 2 since frame 1 is currently being displayed
    for i : 2 .. FRAMES_PLUS1000
        Sprite.ChangePic (frame, plus1000Frames (i))
        delay (DBF)
    end for
        
    Sprite.Free (frame)
end hudIncScore

% Display a circle wipe transition
%
% @param bgClr The colour of the circle in the transition
proc *circleWipe (bgClr : int)
    % @var radii The radius of the circle
    var radii : int := 1

    loop
        radii *= 2
        Draw.FillOval (maxx div 2, maxy div 2, radii, radii, bgClr)

        delay (DBF)
        exit when radii ** 2 >= maxx ** 2 + maxy ** 2
    end loop
end circleWipe
