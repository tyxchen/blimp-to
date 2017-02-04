/**
 * MainGame.t --- main game module for Blimp.to
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

module Game
    import Input, Sprite, Music,
        Canvas, JSON, CommonBtn
    export initLevels,
        initLevelData,
        initScores,
        saveScores,
        playGame

    % @var snapPic A temporary image used to save 
    % @var levelNames An array of the names of the level data files
    var snapPic : int
    var levelNames : flexible array 1 .. 0 of string

    % @var level The current level the game is running through
    % @var angle The angle of the PLA
    % @var frame The current frame that the game is running through
    var level : int := 1
    var angle : int := 90
    var frame : int := 0

    % @var firstPress When the user activates the PLA, checks if this is one press or a continuous
    %                 press
    % @var primeProj Primes the PLA as ready to fire or not
    % @var fireProj Fire the projectile or not
    % @var autoFire Turn on automatic fire or not
    % @var startFireFrame The frame where the user started pressing the firing key
    var firstPress : boolean := true
    var primeProj : boolean := false
    var fireProj : boolean := false
    var autoFire : boolean := false
    var startFireFrame : int

    % @var paused Whether the game is paused or not
    % @var endLevel Whether the level has ended or not
    var paused : boolean := false
    var endLevel : boolean := false

    % @var plas The collection of frames that consist of the PLA in its positions
    % @var pla The current frame displayed as the PLA
    var plas : array 1 .. Pic.Frames (FOLDER_IMAGES + SPRITE_PLA) of int
    var pla : int

    % Initializes the number of levels and fields per level data file
    %
    % @result &numLevels The number of found levels
    % @result &numFields The number of found fields per level data file
    proc initLevels (var numLevels : int, var numFields : int)
        % @var dir Reference to the directory where level data files are stored
        var dir : int
        dir := Dir.Open (FOLDER_LEVELS)

        % Iterate over each of the files in the directory
        loop
            % @var name The name of the currently iterated file
            % @var file The reference to the currently iterated file
            % @var counter A counter for the number of data fields in each file
            var name : string := Dir.Get (dir)
            var file : int
            var counter : int := 0

            exit when name = ""

            % Attempt to open the currently iterated file
            open : file, FOLDER_LEVELS + name, get

            % Only proceed if above operation succeeds and the file is a .json file (level file)
            if file > 0 and index (name, ".json") > 0 then
                % Add a new level
                numLevels += 1
                new levelNames, numLevels
                levelNames (numLevels) := name

                % Count the number of fields in the file
                loop
                    var line : string

                    exit when eof (file)

                    get : file, line : *
                    
                    counter += 1

                    % Update the number of fields only if the counter exceeds the previously saved value
                    if counter > numFields then
                        numFields := counter
                    end if
                end loop

                close : file
            end if
        end loop

        % Close the current directory since we don't need it anymore
        Dir.Close (dir)
    end initLevels

    % Initialize data
    %
    % @result &data An array of the data used to play the game. First dimension is levels, second
    %               dimension fields, third dimension key-value
    proc initLevelData (var data : array 1 .. *, 1 .. *, 1 .. * of string)
        for i : 1 .. upper (data, 1)
            var level : int

            % Open the file containing the current level's data
            open : level, FOLDER_LEVELS + levelNames (i), get

            % Iterate over the fields and populate the data array
            for j : 1 .. upper (data, 2)
                var line : string := ""
                var pair : JSON.Pair

                exit when eof (level)

                get : level, line : *

                JSON.parsePair (line, pair)

                data (i, j, 1) := pair.key
                data (i, j, 2) := pair.value
            end for

            close : level
        end for
    end initLevelData

    % Initialize high scores
    %
    % @result &scores An array of Pairs of level-high score
    proc initScores (var scores : array 1 .. * of JSON.Pair)
        var scoreFile : int
        var scoreData : string := ""

        open : scoreFile, FOLDER_DATA + "scores.json", get

        loop
            var scoreLine : string

            exit when eof (scoreFile)

            get : scoreFile, scoreLine : *

            scoreData += scoreLine
        end loop

        % Convert string data to array
        JSON.toArray (scoreData, scores)

        close : scoreFile
    end initScores

    % Save new high scores
    %
    % @param scores An array of Pairs of level-high score
    proc saveScores (scores : array 1 .. * of JSON.Pair)
        var scoreFile : int
        var scoreData : string
        
        open : scoreFile, FOLDER_DATA + "scores.json", put

        JSON.fromArray (scores, scoreData)

        put : scoreFile, scoreData
        
        close : scoreFile
    end saveScores

    % Detects keys pressed by the user
    process detectKeys
        % @var keys An array containing keys pressed by the user
        var keys : array char of boolean

        loop
            Input.KeyDown (keys)

            % Handle space key event (either fire or unpause)
            if keys (' ') then
                if ~paused then
                    % The game is in a running state, so we treat this as a command to fire the PLA

                    % Set the projectile as primed (ready to fire)
                    primeProj := true

                    % Only trigger the firing if (1) this is the initial keydown event, so that a
                    % single projectile is fired, or (2) automatic fire has been activated
                    if firstPress then
                        startFireFrame := frame
                        fireProj := true
                    elsif autoFire then
                        fireProj := true
                    end if
                else
                    % Unpause the game

                    paused := false
                    Pic.Draw (snapPic, 0, 0, picCopy)
                    Sprite.Show (pla)
                    delay (100)
                end if
            else
                % The user has stopped pressing the space key, so we deactivate all firing-related
                % variables
                firstPress := true
                primeProj := false
                fireProj := false
                autoFire := false
            end if

            % Change direction of PLA
            if keys (KEY_LEFT_ARROW) or keys (KEY_RIGHT_ARROW) then
                % Note that angles are based counterclockwise from a 0 degree vector to the right
                if keys (KEY_LEFT_ARROW) and angle < 180 then
                    angle += 10
                elsif keys (KEY_RIGHT_ARROW) and angle > 0 then
                    angle -= 10
                end if

                Sprite.ChangePic (pla, plas (angle div 10 + 1))

                % Butter-smooth animation, or fine tuning when CTRL is pressed
                if ~keys (KEY_CTRL) then
                    delay (40)
                else
                    delay (100)
                end if
            end if

            if keys ('p') then
                % Pause or unpause the game
                if ~paused then
                    paused := true

                    % Take a screenshot of the game so that the text can be overwritten on unpause
                    snapPic := Pic.New (0, 0, maxx, maxy)
                    fontDraw ("PAUSED", maxx div 2, maxy div 2, FONT_TITLE, ACCENT_BG)
                else
                    paused := false
                    Pic.Draw (snapPic, 0, 0, picCopy)
                    Sprite.Show (pla)
                end if

                delay (100)
            elsif keys ('q') then
                % Quit the game
                endLevel := true
            end if

            Input.Flush

            exit when endLevel
        end loop
    end detectKeys

    % Play the actual game
    %
    % @var data An array containing the starting data for each level
    % @var scores An array containing the high scores for each level
    proc playGame (var data : array 1 .. *, 1 .. *, 1 .. * of string, var scores : array 1 .. * of JSON.Pair)
        % Loop to facilitate seamless transition from one level to the next
        loop
            % This loop runs per level

            % @var canvas The canvas that the game is played on
            % @var score The score of the current game
            var canvas : Canvas
            var score : int := 0

            % @var t The amount of time allocated to this level
            % @var ot The amount of time allocated to each wave in this level
            % @var ammo The amount of ammo allocated to the player in this level
            % @var lives The number of lives that the game starts with
            var t : int := 0
            var ot : int := 0
            var ammo : int := 0
            var lives : int := DEFAULT_LIVES

            % @var waves The number of waves in the level
            % @var numBlimps The number of blimps in the level
            % @var numBombs The number of bombs in the level
            % @var delayBetweenBlimps The delay between blimp-like objects in the level
            % @var blimpMaxY The maximum y-coordinate that blimps can start from
            % @var blimpMaxRange The allowable range of y-coordinates that blimps can start from
            % @var blimpReleased A counter for the number of blimps released per wave
            var waves : int := 0
            var numBlimps : int := 0
            var numBombs : int := 0
            var delayBetweenBlimps : int := DEFAULT_DELAY
            var blimpMaxY : int := 0
            var blimpMaxRange : int := 0
            var blimpReleased : int := 1

            % @var dt A temporary variable for delay time within the PLA sprite
            var dt : int

            % Reset global PLA and game variables
            angle := 90
            frame := 0
            paused := false
            endLevel := false

            circleWipe (DEFAULT_BG)

            % Initialize PLA
            Pic.FileNewFrames (FOLDER_IMAGES + SPRITE_PLA, plas, dt)
            pla := Sprite.New (plas (90 div 10 + 1))
            Sprite.SetPosition (pla, maxx div 2, 100, true)
            Sprite.SetHeight (pla, INFTY)
            Sprite.Show (pla)

            % Initialize canvas
            new canvas

            fork playMusicLoop (MUSIC_BACKGROUNDS (Rand.Int (1, upper (MUSIC_BACKGROUNDS))))

            % Initialize data for this level
            for f : 1 .. upper (data, 2)
                var key : string := data (level, f, 1)
                var val : string := data (level, f, 2)
                
                case key of
                label "time" :
                    ot := strint (val)
                label "ammo" :
                    ammo := strint (val)
                label "waves" :
                    waves := strint (val)
                label "blimps" :
                    numBlimps := strint (val)
                label "maxBlimpY" :
                    blimpMaxY := strint (val)
                label "maxBlimpRange" :
                    blimpMaxRange := strint (val)
                label "delayBetweenBlimps" :
                    delayBetweenBlimps := strint (val)
                label "bombs" :
                    numBombs := strint (val)
                label :
                end case
            end for

            % Initialize time
            t := ot * waves

            % Populate canvas attributes
            canvas -> setNumberOfBlimpsAndBombs (waves, numBlimps, numBombs)
            canvas -> initBlimpsAndBombs (blimpMaxY, blimpMaxRange)
            canvas -> setTime (t)
            canvas -> setAmmo (ammo)
            Sprite.Show (pla)

            % Begin detection of keys
            fork detectKeys

            % Iterate over waves
            for j : 1 .. waves
                canvas -> setWave (j)
                blimpReleased := 1

                % Draw over preexisting content on screen
                Pic.Draw (bgPic, 0, 0, picCopy)

                % Initialize databoxes
                updateBox ("Time", fmtSeconds (t), 0, maxy - DEFAULT_BOX_HEIGHT)
                updateBox ("Score", intstr (score), maxx - DEFAULT_BOX_WIDTH, maxy - DEFAULT_BOX_HEIGHT)
                updateBox ("Lives", intstr (lives), maxx - DEFAULT_BOX_WIDTH, 0)
                updateBox ("Ammo", intstr (ammo), 0, 0)

                % Control the canvas on a per-frame basis
                loop
                    % @var bjon Checks the amount of time that rendering this frame took, so that
                    %           the amount of delay between frames can be dynamically adjusted
                    % @var newScore Any new score that the game may have
                    % @var newLives Any new amount of lives that the game may have
                    var bjon := Time.Elapsed
                    var newScore : int
                    var newLives : int

                    if primeProj then
                        % The PLA is ready to fire

                        if frame - startFireFrame < FPS and ~firstPress then
                            % If it has been less than 1 second since the player started holding
                            % down the fire button, don't fire anything at all
                            autoFire := false
                            fireProj := false
                        else
                            % If it has been more than 1 second, turn on autofire
                            autoFire := true
                            fireProj := true
                            firstPress := false
                        end if
        
                        if fireProj then
                            % Calculate the slope of the projectile from its angle
                            var m : real
        
                            if angle = 90 then
                                m := INFTY
                            else
                                m := tand (angle)
                            end if
                            
                            canvas -> initProjectile (m)
                            canvas -> getAmmo (ammo)
                            updateBox ("Ammo", intstr (ammo), 0, 0)
                        end if
                    end if
        
                    % Run the game only if it's not paused
                    if ~paused then
                        frame += 1

                        % Release the blimp at a predefined interval (delayBetweenBlimps)
                        if frame mod (delayBetweenBlimps * FPS) = 1 and blimpReleased <= (numBlimps + numBombs) then
                            var obj : string := canvas -> releaseBlimp (j, blimpReleased)
                            
                            blimpReleased += 1
                        end if

                        % Update the time every second
                        if frame mod FPS = 0 then
                            canvas -> setTime (t - 1)
                            canvas -> getTime (t)
                            
                            updateBox ("Time", fmtSeconds (t), 0, maxy - DEFAULT_BOX_HEIGHT)
                        end if

                        % Update the canvas
                        canvas -> update
                        canvas -> getScore (newScore)
                        canvas -> getLives (newLives)
                        canvas -> getAmmo (ammo)

                        % Actions if the score has changed (a blimp has been shot down)
                        if newScore ~= score then
                            fork playMusic (MUSIC_SUCCESS)
                            updateBox ("Score", intstr (newScore), maxx - DEFAULT_BOX_WIDTH, maxy - DEFAULT_BOX_HEIGHT)
                            updateBox ("Ammo", intstr (ammo), 0, 0)
                            score := newScore
                        end if

                        % Actions if the number of lives has changed (a bomb has been shot down)
                        if newLives ~= lives then
                            fork playMusic (MUSIC_FAIL)
                            updateBox ("Lives", intstr (newLives), maxx - DEFAULT_BOX_WIDTH, 0)
                            lives := newLives
                        end if

                        % Exit the level once the game has stopped running
                        if canvas -> isRunning = false then
                            endLevel := true
                        end if
                    end if

                    % Dynamic delay between frames for a consistent frame rate

                    bjon := Time.Elapsed - bjon

                    if bjon < DBF then
                        delay (DBF - bjon)
                    else
                        % BJON_DEBUG (intstr (bjon) + "\n")
                    end if

                    % Display transition if the level has ended
                    if endLevel then
                        circleWipe (DEFAULT_FG)
                        exit
                    end if

                    % Exit when the current wave has ended
                    exit when frame / FPS mod ot = 0 and t < waves * ot and t > 0
                end loop

                exit when endLevel

                fontDraw ("NEW WAVE", maxx div 2, maxy div 2, FONT_TITLE, ACCENT_BG)
                delay (3000)

                % Prevent objects from the previous wave from polluting the canvas on the next wave
                canvas -> hideAll
            end for

            % Level has ended, so we clear the canvas and paint it black

            canvas -> clearAll

            Sprite.Hide (pla)
            Sprite.Free (pla)

            for p : 1 .. upper (plas)
                Pic.Free (plas (p))
            end for

            Draw.FillBox (0, 0, maxx, maxy, DEFAULT_FG)

            delay (1000)

            % Post-level operations

            % @var blimp The hero blimp displayed on the game over screen
            var blimp : int := Pic.FileNew (FOLDER_IMAGES + SPRITE_BLIMP_RIGHT)

            % @var str The message to display depending on whether the player won or lost
            % @var highScore Whether the score achieved was a high score
            var str : string
            var highScore : boolean := false

            % @var buttons An array of buttons to display for further actions
            % @var currentBtn The button currently selected
            % @var showExitBtn Whether or not the exit button is shown
            % @var arrows An array of keys pressed by the user
            var buttons : array 1 .. 3 of CommonBtn.Btn
            var currentBtn := 1
            var showExitBtn : boolean := false
            var arrows : array char of boolean

            % @var $tryAgainBtn The button that lets the user try the level again
            % @var $nextLevelBtn The button that lets the user advance to the next level, or give
            %                    up if they lost
            % @var $exitBtn The button that lets the user exit the game on a win
            bind var tryAgainBtn to buttons (1)
            bind var nextLevelBtn to buttons (2)
            bind var exitBtn to buttons (3)

            Pic.Draw (blimp, (maxx - Pic.Width (blimp)) div 2, maxy div 2 + 48, picMerge)

            if canvas -> isWin then
                str := "YOU WIN" % :)
            else
                str := "YOU LOST" % :(
            end if

            fontDraw (str, maxx div 2, maxy div 2, FONT_TITLE, ACCENT_BG)

            % Calculate the final score
            % #secretsauce
            if score > 0 then
                score += lives * 100 + ammo * 10
            end if

            % Check if this is a high score --- if it is, mark it as such and update the scores
            for s : 1 .. upper (scores)
                if intstr (level) = scores (s).key then
                    if score > strint (scores (s).value) then
                        highScore := true
                        scores (s).value := intstr (score)
                    end if
                end if
            end for

            % Draw a special tag and save scores if there was a high score, otherwise just print
            % out a regular score
            if highScore then
                fontDraw ("Score: " + intstr (score), maxx div 2, maxy div 2 - 36, FONT_BTN, ACCENT_BG)
                fontDraw ("HIGH SCORE!!!", maxx div 2, maxy div 2 - 64, FONT_BTN, 4)

                saveScores (scores)
            else
                fontDraw ("Score: " + intstr (score), maxx div 2, maxy div 2 - 48, FONT_BTN, ACCENT_BG)
            end if

            % Initialize buttons
            CommonBtn.initBtn (tryAgainBtn, "TRY AGAIN", maxx div 2, maxy div 2 - 110, 200, 24, ACCENT_BG, ACCENT_FG, FONT_BTN, true)
            CommonBtn.initBtn (nextLevelBtn, "NEXT LEVEL", maxx div 2, maxy div 2 - 150, 200, 24, ACCENT_BG, ACCENT_FG, FONT_BTN, true)

            CommonBtn.drawBtn (tryAgainBtn)
            CommonBtn.drawBtn (nextLevelBtn)

            exitBtn.selected := false

            if canvas -> isWin and level < upper (data, 1) then
                % If this was a win and it wasn't the last level, draw the exit button and select
                % the next level button as the default
                CommonBtn.selectBtn (nextLevelBtn)
                CommonBtn.initBtn (exitBtn, "EXIT", maxx div 2, maxy div 2 - 190, 200, 24, ACCENT_BG, ACCENT_FG, FONT_BTN, true)
                CommonBtn.drawBtn (exitBtn)
                currentBtn := 2
                showExitBtn := true
            else
                % This wasn't a win, so the next level button's text is changed
                nextLevelBtn.text := "I GIVE UP"
                CommonBtn.drawBtn (nextLevelBtn)
                CommonBtn.selectBtn (tryAgainBtn)
            end if

            if level = upper (data, 1) then
                % If this is the last level, advancing to the "next" level exits the game
                nextLevelBtn.text := "EXIT"
                CommonBtn.drawBtn (nextLevelBtn)
            end if

            % Detect keyboard input
            loop
                Input.Pause
                Input.KeyDown (arrows)

                if arrows (KEY_UP_ARROW) and currentBtn > 1 then
                    % Go up in the button stack
                    currentBtn -= 1
                    CommonBtn.selectBtn (buttons (currentBtn))
                    CommonBtn.drawBtn (buttons (currentBtn + 1))
                elsif arrows (KEY_DOWN_ARROW) and currentBtn < upper (buttons) then
                    % Go down in the button stack, but only if this is not the last visible exit
                    % button
                    if (~showExitBtn and currentBtn + 1 < upper (buttons)) or showExitBtn then
                        currentBtn += 1
                        CommonBtn.selectBtn (buttons (currentBtn))
                        CommonBtn.drawBtn (buttons (currentBtn - 1))
                    end if
                elsif arrows (KEY_ENTER) or arrows (' ') then
                    % Commit to action
                    if tryAgainBtn.selected then
                        % Try again button selected
                        exit
                    elsif nextLevelBtn.selected and canvas -> isWin then
                        % Next level selected and player won, so level-up
                        level += 1
                        exit
                    elsif nextLevelBtn.selected and canvas -> isWin = false then
                        % Next level selected and player lost, so exit game by setting level to
                        % beyond the number of levels
                        level := upper (data, 1) + 1
                        exit
                    elsif exitBtn.selected then
                        % Exit in the same way as above
                        level := upper (data, 1) + 1
                        exit
                    end if
                end if
            end loop
            
            % Cleanup everything
            playMusicStop
            
            free canvas
            
            exit when level > upper (data, 1)
        end loop
        
        level := 1
    end playGame
end Game
