/**
 * canvasClass.tu --- Defines and manages behaviour within the canvas
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

class CanvasClass
    import Math, Blimp, Projectile, Bomb
    
    export getTime, setTime,
        getAmmo, setAmmo,
        getScore,
        getLives,
        getWave, setWave,
        setNumberOfBlimpsAndBombs,
        update,
        initBlimpsAndBombs, releaseBlimp,
        initProjectile,
        hideAll, clearAll,
        isRunning, isWin

    % @var t The time elapsed since the start of the game
    % @var ammo The amount of ammo that the player has
    % @var score The score of the game
    % @var lives The number of lives that the player has left
    % @var curWave The current wave of the current level that the class is handling
    % @var aliveBlimps The number of alive (not shot at) blimps
    % @var aliveBombs The number of alive (not shot at) bombs
    var t : int := 0
    var ammo : int := 0
    var score : int := 0
    var lives : int := DEFAULT_LIVES
    var curWave : int
    var aliveBlimps : int
    var aliveBombs : int
    
    % @var blimp An array containing the blimps/bombs in play for the game
    var blimps : flexible array 1 .. 0, 1 .. 0, 1 .. 1 of Blimp
    
    % @var projectiles An array containing the projectiles in play/played for the game
    var projectiles : flexible array 1 .. 0 of Projectile
    
    % Returns the time elapsed since the start of the game
    %
    % @result &i
    proc getTime (var i : int)
        i := t
    end getTime
    
    % Sets elapsed time for the canvas, since the canvas does not have any internal time-counting
    % abilities. 
    %
    % @param i The elapsed time
    proc setTime (i : int)
        t := i
    end setTime
    
    % Returns the amount of ammo in the game
    %
    % @result &a
    proc getAmmo (var a : int)
        a := ammo
    end getAmmo
    
    % Sets the amount of ammo in the game
    %
    % @param a The desired amount of ammo
    proc setAmmo (a : int)
        ammo := a
    end setAmmo
    
    % Returns the score of the game
    %
    % @result &s
    proc getScore (var s : int)
        s := score
    end getScore
    
    % Returns the number of lives that the player has
    %
    % @result &l
    proc getLives (var l : int)
        l := lives
    end getLives
    
    % Returns the wave that the canvas is currently rendering
    %
    % @result &w
    proc getWave (var w : int)
        w := curWave
    end getWave
    
    % Sets the wave that the canvas should render
    %
    % @param w The desired wave to render
    proc setWave (w : int)
        if w <= upper (blimps, 1) then
            curWave := w
        else
            Error.Halt ("Error! Wave set to value beyond upper bound of array.")
        end if
    end setWave
    
    % Sets the number of waves, blimps, and bombs, by resizing the `blimps` array so that it can
    % fit all of the objects, and initializing `aliveBlimps` and `aliveBombs`
    %
    % @param w The desired number of waves in the canvas
    % @param n The desired number of blimps in the canvas
    % @param b The desired number of bombs in the canvas
    proc setNumberOfBlimpsAndBombs (w : int, n : int, b : int)
        new blimps, w, n + b, 1
        aliveBlimps := w * n
        aliveBombs := w * b
    end setNumberOfBlimpsAndBombs
    
    % Updates the objects on the canvas
    proc update
        % Iterate over each of the blimps in the current wave
        for b : 1 .. upper (blimps, 2)
            % @var ox The x-coordinate of the currently iterated blimp
            % @var oy The y-coordinate of the currently iterated blimp
            % @var bdir The direction that the currently iterated blimp is travelling in
            var ox : int
            var oy : int
            var bdir : int

            % Get the properties described above
            blimps (curWave, b, 1) -> getPos (ox, oy)
            blimps (curWave, b, 1) -> getDir (bdir)

            % Only update and check for collisions if the blimp is on the canvas
            if blimps (curWave, b, 1) -> isBanished = false then
                % Iterate over each projectile to check for collision
                for p : 1 .. upper (projectiles)
                    % Only continue if the projectile can be interacted with
                    if projectiles (p) -> isAlive then
                        % @var px The x-coordinate of the currently iterated projectile
                        % @var py The y-cooridnate of the currently iterated projectile
                        var px : int
                        var py : int

                        % Get the properties described above
                        projectiles (p) -> getPos (px, py)
                        
                        % Check for collision and execute if and only if:
                        %
                        % 1) Make sure the blimp can be interacted with, and;
                        % 2) The projectile intersects the blimp, and;
                        % 3) The projectile does not intersect the blimp outside of the bounds of the
                        %    canvas
                        if blimps (curWave, b, 1) -> isAlive and blimps (curWave, b, 1) -> entersBoundingBox (px, py) and
                                (0 < px and px < maxx) and (0 < py and py < maxy) then
                            % Shoot the blimp so that it is disabled, and kill the projectile so
                            % that it no longer appears on the screen or has an effect
                            blimps (curWave, b, 1) -> shoot (score)
                            projectiles (p) -> kill
                            
                            % Perform different behaviour based on the type of object
                            case blimps (curWave, b, 1) -> instanceOf of
                            label "BlimpClass":
                                % The object is a blimp, so we remove a blimp and reward the user
                                aliveBlimps -= 1
                                ammo += 5
                            label "BombClass":
                                % The object is a bomb, so we remove a bomb and penalize the user
                                aliveBombs -= 1
                                lives -= 1
                            label:
                                % We have no idea what the object is, so we halt and catch fire
                                Error.Halt ("ERROR: Class '" + blimps (curWave, b, 1) -> instanceOf + "' not found")
                            end case
                            
                            % Now that the projectile has successfully interacted with the blimp,
                            % no other projectile can interact with this blimp, so we save
                            % ourselves some CPU time and continue onto the next blimp
                            exit
                        end if
                    end if
                end for

                % Update the position of the blimp on the canvas
                blimps (curWave, b, 1) -> update
            end if

            % If a blimp reaches the opposite side of the canvas without being shot down, penalize
            % the user
            if blimps (curWave, b, 1) -> isAlive and blimps (curWave, b, 1) -> instanceOf = "BlimpClass" then
                if (bdir = 1 and ox > maxx) or (bdir = -1 and ox < 0) or (0 > oy or oy > maxy) then
                    aliveBlimps -= 1
                    lives -= 1
                    blimps (curWave, b, 1) -> stab
                end if
            end if
        end for

        % Iterate over each interactable projectile and update its position
        for p : 1 .. upper (projectiles)
            if projectiles (p) -> isAlive then
                projectiles (p) -> update
            end if
        end for
    end update

    % Initialize the positions of each blimp and bomb, in limbo
    %
    % @param ymax The maximum distance from the top that blimps can start at
    % @param yrange The range of y-distances that the blimps can start at from `ymax`
    proc initBlimpsAndBombs (ymax : int, yrange : int)
        % Iterate over each wave
        for i : 1 .. upper (blimps, 1)
            % @var numBombs The number of bombs per wave
            % @var bombPositions A string containing the positions in the `blimps` array where a
            %                    bomb will be initialized
            var numBombs : int := aliveBombs div upper (blimps, 1)
            var bombPositions : string := " "
            
            % Randomly determine the positions of bombs in `blimps`
            for j : 1 .. numBombs
                % @var uLim The highest position where a bomb can be placed. Calculated by
                %           determining the size of the intervals within which a bomb can
                %           be placed without overstepping into another interval
                % @var lLim The lowest position where a bomb can be placed
                var uLim : int := j * upper (blimps, 2) div numBombs
                var lLim : int := uLim - upper (blimps, 2) div numBombs + 1

                % Randomly generate the position given the abovementioned limits
                bombPositions += intstr (Rand.Int (lLim, uLim)) + " "
            end for

            % Iterate over each position in a wave
            for k : 1 .. upper (blimps, 2)
                if index (bombPositions, " " + intstr (k) + " ") = 0 then
                    % Not a position for a bomb, so a blimp is initialized
                    var b : Blimp
                    
                    new b
                    
                    b -> setCanvasBounds (maxx, maxy)
                    b -> setRandomStartParams (ymax, yrange)
                    b -> setSpeed (0)
                    b -> create
                    
                    blimps (i, k, 1) := b
                else
                    % A position for a bomb, so a bomb is initialized
                    var b : Bomb
                    
                    new b
                    
                    b -> setCanvasBounds (maxx, maxy)
                    b -> setRandomStartParams (ymax, yrange)
                    b -> setSlope (0) % Bombs only travel horizontally, making them easier to hit
                    b -> setSpeed (0)
                    b -> create
                    
                    blimps (i, k, 1) := b
                end if
            end for
        end for
    end initBlimpsAndBombs

    % Releases a blimp from limbo into the canvas, then returns the type of blimp released
    %
    % @param w The wave to release the blimp from
    % @param b The blimp to release
    %
    % @result The type of blimp released
    fcn releaseBlimp (w : int, b : int) : string
        blimps (w, b, 1) -> setSpeed (BLIMP_SPEED)
        blimps (w, b, 1) -> update
        
        result blimps (w, b, 1) -> instanceOf
    end releaseBlimp

    % Initializes the position of a projectile
    %
    % @param m The slope to initialize the projectile with
    proc initProjectile (m : real)
        if ammo <= 0 then
            % Do not initialize the projectile if the player has 0 ammo
            return
        end if
        
        var p : Projectile
        new p
        
        % Initialize the projectile's parameters
        p -> setPos (maxx div 2, 75)
        p -> setSpeed (PROJECTILE_SPEED)
        p -> setSlope (m)
        
        p -> create
        p -> update
        
        % Subtract 1 from the player's ammunition count
        ammo -= 1
        
        new projectiles, upper (projectiles) + 1
        projectiles (upper (projectiles)) := p
    end initProjectile

    % Hide all objects on the canvas
    proc hideAll
        for w : 1 .. upper (blimps, 1)
            for b : 1 .. upper (blimps, 2)
                blimps (w, b, 1) -> hide
            end for
        end for
            
        for p : 1 .. upper (projectiles)
            projectiles (p) -> hide
        end for
    end hideAll

    % Clear the canvas by destroying all of its objects
    proc clearAll
        for w : 1 .. upper (blimps, 1)
            for b : 1 .. upper (blimps, 2)
                blimps (w, b, 1) -> kill
            end for
        end for
            
        for p : 1 .. upper (projectiles)
            projectiles (p) -> kill
        end for
    end clearAll

    % Returns whether or not the game is running
    %
    % @result `true` if the game is running, otherwise `false`
    fcn isRunning : boolean
        result t > 0 and ammo > 0 and lives > 0
    end isRunning
    
    % Returns whether or not the player won the game
    %
    % @result `true` if the player won, otherwise `false`
    fcn isWin : boolean
        result lives > 0 and aliveBlimps = 0
    end isWin
end CanvasClass

type Canvas : ^CanvasClass
