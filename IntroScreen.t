/**
 * IntroScreen.t --- contains procedures regarding the intro screen for Blimp.to
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

module Intro
    import Input, Sprite, Str,
        Canvas, JSON, CommonBtn
    export drawIntro
    
    % @var exitIntro Switch to exit the intro screen. Used to facilitate application of settings
    var exitIntro : boolean := true
    
    % Draw a sub-window for settings on the screen
    % Primitive, but hey it works
    proc drawSettings
        % @var margin The margin imposed on the subwindow
        var margin : int := 100

        % @var userName The user name entered by the user
        % @var withSound The user preference for sound (on/off)
        var userName : string := settings (1).value
        var withSound : string := settings (2).value

        % @var userNameString The string to display when asking for a new user name
        % @var withSoundString The string to display when asking for preference on sound
        var userNameString : string := "Enter a new name:"
        var withSoundString : string := "Sound on/off:"

        Draw.FillBox (margin, margin, maxx - margin, maxy - margin, ACCENT_BG)

        % Draw fields for the user name
        Font.Draw (userNameString, margin + DEFAULT_PADDING, maxy - 200, FONT_TITLE, DEFAULT_BG)
        Font.Draw (userName, margin + Font.Width (userNameString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 200, FONT_TITLE, ACCENT_FG)
        
        % Draw fields for the sound preference
        Font.Draw (withSoundString, margin + DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)

        if withSound = "on" then
            Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_FG)
            Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
        else
            Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
            Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_FG)
        end if

        % Get a username
        loop
            % @var done Whether the user has finished inputting their username
            % @var ch A character inputted by the user
            var done : boolean := false
            var ch : string (1)

            getch (ch)

            % Draw over previously drawn text
            Draw.FillBox (margin + Font.Width (userNameString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 200, maxx - margin, maxy - 150, ACCENT_BG)
            Draw.FillBox (margin + DEFAULT_PADDING, maxy - 250, maxx - margin, maxy - 205, ACCENT_BG)

            % User has entered a character; now we perform character validation
            if ("A" < ch and ch < "Z") or ("a" < ch and ch < "z") or ("0" < ch and ch < "9") then
                % If the character is valid and we haven't reached the 20-character limit, add it
                % to the user name, otherwise display an error message
                if length (userName) < 20 then
                    userName += ch
                else
                    Font.Draw ("Usernames must contain 20 characters or less", margin + DEFAULT_PADDING, maxy - 225, FONT_BTN, SPECIAL_FG)
                end if
            elsif ch = KEY_BACKSPACE then
                % If the character is a backspace character, subtract the last character if possible
                if length (userName) > 0 then
                    userName := userName (1 .. * - 1)
                end if
            elsif ch = KEY_LEFT_ARROW or ch = KEY_RIGHT_ARROW or ch = KEY_UP_ARROW or ch = KEY_DOWN_ARROW then
                % If the character is an arrow key, do nothing but show a message
                Font.Draw ("Arrow keys not supported", margin + DEFAULT_PADDING, maxy - 225, FONT_BTN, SPECIAL_FG)
            elsif ch = KEY_ENTER then
                % If the character is an enter key, mark this field as completed
                done := true
            else
                Font.Draw ("Alphanumeric characters only!", margin + DEFAULT_PADDING, maxy - 225, FONT_BTN, SPECIAL_FG)
            end if

            % Draw the changed username onto the screen
            Font.Draw (userName, margin + Font.Width (userNameString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 200, FONT_TITLE, ACCENT_FG)

            % Prevent overflow of the keyboard buffer
            Input.Flush

            exit when done
        end loop

        % Change the colours of the two fields as we transition from one to the other

        Font.Draw (userName, margin + Font.Width (userNameString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 200, FONT_TITLE, DEFAULT_BG)

        if withSound = "on" then
            Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, ACCENT_FG)
            Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
        else
            Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
            Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, ACCENT_FG)
        end if

        % Get user's preference for sound
        loop
            var done : boolean := false
            var pref : boolean := (withSound = "on")
            var ch : string (1)

            getch (ch)

            if ch = KEY_LEFT_ARROW or ch = KEY_RIGHT_ARROW or ch = KEY_UP_ARROW or ch = KEY_DOWN_ARROW then
                % Invert choice
                pref := ~pref
            elsif ch = KEY_ENTER or ch = ' ' then
                % If the character is an enter key or a space, mark this field as completed
                done := true
            end if

            % Draw the changed preference onto the screen
            if pref then
                withSound := "on"
                Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, ACCENT_FG)
                Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
            else
                withSound := "off"
                Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
                Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, ACCENT_FG)
            end if

            Input.Flush

            exit when done
        end loop

        if withSound = "on" then
            Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_FG)
            Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
        else
            Font.Draw ("ON", margin + Font.Width (withSoundString, FONT_TITLE) + 2 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_BG)
            Font.Draw ("OFF", margin + Font.Width (withSoundString + "ON", FONT_TITLE) + 3 * DEFAULT_PADDING, maxy - 300, FONT_TITLE, DEFAULT_FG)
        end if

        % Save settings to the settings array
        settings (1).value := userName
        settings (2).value := withSound

        % Save settings to file
        saveSettings

        Font.Draw ("Saved!", margin + DEFAULT_PADDING, maxy - 400, FONT_TITLE, DEFAULT_BG)

        delay (1000)

        Music.PlayFileStop
    end drawSettings

    % Draw the intro screen
    proc drawIntro
        % Loop to facilitate instant application of changed settings
        loop
            % @var currentBtn The currently selected button
            % @var introOverlay An overlay containing the title of the game onto the background
            var currentBtn : int := 1
            var introOverlay : int

            % @var arrows An array of keys pressed. Used to control buttons
            % @var buttons An array of buttons to display onscreen
            % @var $playGame A button to play the game
            % @var $playTutorial A button to play the tutorial
            % @var $editSettings A button to edit the settings
            % @var $exitGame A button to exit the game
            var arrows : array char of boolean
            var buttons : array 1 .. 4 of CommonBtn.Btn
            bind var playGame to buttons (1)
            bind var playTutorial to buttons (2)
            bind var editSettings to buttons (3)
            bind var exitGame to buttons (4)

            % Set any action to exit the intro screen by default
            exitIntro := true
            initSettings

            Pic.Draw (bgPic, 0, 0, picCopy)
            
            introOverlay := Pic.FileNew (FOLDER_IMAGES + "intro.gif")
            Pic.Draw (introOverlay, 0, 0, picMerge)	

            % If the user has set a name, display it; otherwise, display the game's tagline
            if length (settings (1).value) > 0 then
                fontDraw ("Hello " + settings (1).value + "!", maxx div 2, maxy - 330, FONT_TITLE, ACCENT_BG)
            else
                fontDraw ("Shoot the runaway blimps!", maxx div 2, maxy - 330, FONT_TITLE, ACCENT_BG)
            end if

            % Initialize buttons
            CommonBtn.initBtn (playGame, "PLAY", maxx div 2, maxy div 2 - 100, 250, 36, ACCENT_BG, ACCENT_FG, FONT_TITLE, true)
            CommonBtn.initBtn (playTutorial, "TUTORIAL", maxx div 2, maxy div 2 - 150, 250, 36, ACCENT_BG, ACCENT_FG, FONT_TITLE, true)
            CommonBtn.initBtn (editSettings, "SETTINGS", maxx div 2, maxy div 2 - 200, 250, 36, ACCENT_BG, ACCENT_FG, FONT_TITLE, true)
            CommonBtn.initBtn (exitGame, "EXIT", maxx div 2, maxy div 2 - 255, 250, 24, ACCENT_BG, SPECIAL_FG, FONT_BTN, true)

            for b : 1 .. upper (buttons)
                CommonBtn.drawBtn (buttons (b))
            end for

            CommonBtn.selectBtn (playGame)

            % Add subtle hint for credits screen
            fontDraw ("Press CTRL + I for credits", maxx div 2, 8, FONT_BOX_LABEL, DEFAULT_FG)

            fork playMusicLoop (MUSIC_INTROS (Rand.Int (1, upper (MUSIC_INTROS))))

            % Handle buttons
            loop
                Input.Pause
                Input.KeyDown (arrows)
                
                if arrows (KEY_UP_ARROW) and currentBtn > 1 then
                    % Go up in the button stack
                    currentBtn -= 1
                    CommonBtn.selectBtn (buttons (currentBtn))
                    CommonBtn.drawBtn (buttons (currentBtn + 1))
                elsif arrows (KEY_DOWN_ARROW) and currentBtn < upper (buttons) then
                    % Go down in the button stack
                    currentBtn += 1
                    CommonBtn.selectBtn (buttons (currentBtn))
                    CommonBtn.drawBtn (buttons (currentBtn - 1))
                elsif arrows (KEY_ENTER) or arrows (' ') then
                    % A button has been selected
                    if playGame.selected then
                        % Exit the intro screen directly into the game
                        exit
                    elsif playTutorial.selected then
                        % Display the tutorial, and once that is done reload the intro screen
                        include "Tutorial.t"
                        exitIntro := false
                        exit
                    elsif editSettings.selected then
                        % Display the settings dialog, and then reload the intro screen
                        drawSettings
                        exitIntro := false
                        exit
                    elsif exitGame.selected then
                        % Exit the game in its entirity
                        stop := true
                        exit
                    end if
                elsif arrows (KEY_CTRL) and arrows ('i') then
                    % someone wants info! We display the credits window
                    % @var infoWindow The window opened to display info
                    % @var licenseFile A stream identifier for the license files displayed
                    var infoWindow : int := Window.Open ("position:top;center,text:600;400,nobuttonbar")
                    var licenseFile : int

                    put "BLIMP.TO by TERRY CHEN"
                    put "A Grade 11 Computer Science final project"

                    put "\nMUSIC CREDITS\n"

                    % Open the license file for the music used

                    open : licenseFile, FOLDER_MUSICS + "LICENSES.txt", get

                    loop
                        var line : string

                        exit when eof (licenseFile)

                        get : licenseFile, line : *
                        put line
                    end loop

                    close : licenseFile

                    put "\nIMAGE CREDITS\n"

                    % Open the license file for the images used

                    open : licenseFile, FOLDER_IMAGES + "LICENSES.txt", get

                    loop
                        var line : string

                        exit when eof (licenseFile)

                        get : licenseFile, line : *
                        put line
                    end loop

                    close : licenseFile

                    put "\nMORAL SUPPORT CREDITS: ALMEN NG, BJON LI, CHRISTOPHER WONG\n"
                    put "\nPRESS ANY KEY TO EXIT"

                    % Exit the credits window when a key is pressed
                    loop
                        exit when hasch
                    end loop

                    Window.Close (infoWindow)
                end if
            end loop

            % Stop music and free the overlay to prevent any stack/memory issues
            Music.PlayFileStop
            Pic.Free (introOverlay)

            exit when exitIntro
        end loop
    end drawIntro
end Intro
