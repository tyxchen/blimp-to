/**
 * constants.tu --- Contains constants to be used throughout the program
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

module Constants
    % Export the constants - unqualified means that they are defined in the global namespace, and
    % pervasive means that they do not need to be imported into modules, etc. 
    export unqualified pervasive all

    /** GENERAL UBER-IMPORTANT CONSTANTS **/
    
    % @const INFTY A placeholder constant for infinity
    % @const FPS The number of frames per second that the game runs at
    % @const DBF The delay between frames, in milliseconds
    const INFTY : int := 16#FFFFFF
    const FPS : int := 25
    const DBF : int := 1000 div FPS

    /** FILE CONSTANTS **/

    % @const FOLDER_IMAGES The folder in which images are stored
    % @const FOLDER_LEVELS The folder in which level data files are stored
    % @const FOLDER_MUSICS The folder in which music files are stored
    % @const FOLDER_DATA The folder in which user data files are stored
    const FOLDER_IMAGES : string := "etc/images/"
    const FOLDER_LEVELS : string := "etc/levels/"
    const FOLDER_MUSICS : string := "etc/musics/"
    const FOLDER_DATA : string := "etc/data/"
    
    % @const SPRITE_BLIMP_RIGHT The sprite for blimps travelling rightwards
    % @const SPRITE_BLIMP_LEFT The sprite for blimps travelling leftwards
    % @const SPRITE_BOMB The sprite for a bomb
    % @const SPRITE_PROJECTILE The sprite for projectiles
    % @const SPRITE_PLA The sprite for a PLA
    % @const SPRITE_PLUS1000 The sprite for the '+1000' HUD that appears when a blimp is hit
    const SPRITE_BLIMP_RIGHT : string := "blimp_right.gif"
    const SPRITE_BLIMP_LEFT : string := "blimp_left.gif"
    const SPRITE_BOMB : string := "bomb.gif"
    const SPRITE_PROJECTILE : string := "projectile.gif"
    const SPRITE_PLA : string := "pla.gif"
    const SPRITE_PLUS1000 : string := "plus1000-noalpha.gif"
    
    % @const MUSIC_INTROS An array of filenames referencing music to be played in the intro
    % @const MUSIC_BACKGROUNDS An array of filenames referencing music to be played during the game
    % @const MUSIC_SUCCESS The filename of the tone to be played on a success
    % @const MUSIC_FAIL The filename of the tone to be played on a failure
    const MUSIC_INTROS : array 1 .. 3 of string := init ("Casa Bossa Nova.mp3", "Meatball Parade.mp3", "Mischief.mp3")
    const MUSIC_BACKGROUNDS : array 1 .. 4 of string := init ("Mighty Like Us.mp3", "Overworld.mp3", "Pixelland.mp3", "Run Amok.mp3")
    const MUSIC_SUCCESS : string := "Two Tone Doorbell.wav"
    const MUSIC_FAIL : string := "Elephant.wav"

    /** GAME CONSTANTS **/

    % @const BLIMP_SPEED The default speed that a blimp travels at
    % @const PROJECTILE_SPEED The default speed that a projectile travels at
    const BLIMP_SPEED : int := 4
    const PROJECTILE_SPEED : int := 20

    % @const DEFAULT_LIVES The default number of lives that the user starts with
    % @const DEFAULT_DELAY The default interval between blimp releases during the game
    const DEFAULT_LIVES : int := 3
    const DEFAULT_DELAY : int := 5

    /** STYLE CONSTANTS **/

    % @const DEFAULT_BOX_WIDTH The default width of a databox on the screen
    % @const DEFAULT_BOX_HEIGHT The default height of a databox on the screen
    % @const DEFAULT_PADDING The default amount of padding to use in formatting
    const DEFAULT_BOX_WIDTH : int := 80
    const DEFAULT_BOX_HEIGHT : int := 36
    const DEFAULT_PADDING : int := 10

    % @const DEFAULT_BG Default background colour
    % @const DEFAULT_FG Default foreground colour
    % @const ACCENT_BG Accent background colour
    % @const ACCENT_FG Accent foreground colour
    % @const SPECIAL_FG Special foreground colour
    const DEFAULT_BG : int := 0
    const DEFAULT_FG : int := 17
    const ACCENT_BG : int := 6
    const ACCENT_FG : int := 11
    const SPECIAL_FG : int := 4

    % @const FONT_BOX Font to use for databoxes
    % @const FONT_BOX_LABEL Font to use for databox labels
    % @const FONT_TITLE Font to use for titles
    % @const FONT_BTN Font to use in buttons
    const FONT_BOX : int := Font.New ("Consolas:16")
    const FONT_BOX_LABEL : int := Font.New ("Consolas:10")
    const FONT_TITLE : int := Font.New ("Consolas:24:bold")
    const FONT_BTN : int := Font.New ("Consolas:16:bold")
end Constants
