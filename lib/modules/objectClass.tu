/**
 * objectClass.tu --- Contains class and type definitions for on-screen objects
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

% Mothership class for all objects
class ObjectClass
    import Sprite
    export instanceOf,
        getSpeed, setSpeed,
        getPos, setPos,
        getFuturePos,
        getSlope, setSlope,
        updatePos,
        entersBoundingBox,
        isAlive, isBanished,
        draw, initialize, create,
        hide, stab, kill,
        update
    
    % @const TYPE The type of the object. Editable to identify between children
    % @const SPEED The speed that the object travels at
    var TYPE : string := "ObjectClass"
    var SPEED : int
    
    % @var alive If the object is alive (non-responsive, may be in use/used again)
    % @var banished If the object is completely, 100% dead (will not be used again)
    % @var m The vector that the object travels on (direction * delta of Y / delta of X)
    % @var x The current x-position of the object
    % @var y The current y-position of the object
    var alive : boolean := true
    var banished : boolean := false
    var m : real
    var x : int
    var y : int
    
    % @var sprites An array of the frames of the sprite used for this object
    % @var sprite An ID corresponding to the Sprite object used for this object
    % @var spriteH The height of the sprite
    % @var spriteW The width of the sprite
    var sprites : flexible array 1 .. 0 of int
    var sprite : int
    var spriteH : int
    var spriteW : int
    
    % Returns the instance of the current object
    %
    % @result
    fcn instanceOf : string
        result TYPE
    end instanceOf
    
    % Returns the currently defined speed of the current object
    %
    % @result &pv The defined speed
    proc getSpeed (var pv : int)
        pv := SPEED
    end getSpeed
    
    % Sets the speed for the current object
    %
    % @param pv The desired speed
    proc setSpeed (pv : int)
        SPEED := pv
    end setSpeed
    
    % Returns the x- and y-coordinates of the current object
    %
    % @result &px The x-coordinate of the object
    % @result &py The y-coordinate of the object
    proc getPos (var px : int, var py : int)
        px := x
        py := y
    end getPos
    
    % Sets the x- and y-coordinates of the current object
    %
    % @param px The desired x-coordinate
    % @param py The desired y-coordinate
    proc setPos (px : int, py : int)
        x := px
        y := py
    end setPos
    
    % Returns the position of the current object at a specific time in the future from now
    %
    % @param t The time, from now, at which to calculate the object's position
    % @param px The x-coordinate of the object in the future
    % @param py The y-coordinate of the object in the future
    proc getFuturePos (t : int, var px : int, var py : int)
        if m < INFTY then
            % Object not travelling vertically
            
            % @var deltaX The x-difference between the future and now. Calculated using the formula
            %             for deriving the height of a right triangle given hypotenuse and tan A
            % @var sgn The sign of the slope of the object, to control direction
            var deltaX : real := t * SPEED / sqrt (m ** 2 + 1)
            var sgn : int := sign (m)
            
            % If m = 0 (horizontal line), make sgn = 1 as we multiply sgn with deltaX later on
            if sgn = 0 then
                sgn := 1
            end if
            
            % Calculate future positions
            px := round (x + sgn * deltaX)
            py := round (y + abs (m * deltaX))
        else
            % Object travelling vertically
            px := x
            py := t * SPEED + y
        end if
    end getFuturePos
    
    % Returns the slope that the current object is travelling at
    %
    % @result &pm
    proc getSlope (var pm : real)
        pm := m
    end getSlope
    
    % Sets the slope of the current object
    %
    % @param pm The desired slope
    proc setSlope (pm : real)
        m := pm
    end setSlope
    
    % Update the coordinates of the current object by its speed over its vector (slope)
    proc updatePos
        if m < INFTY then
            % Object not travelling vertically
            
            % @var deltaX The x-difference between the future and now. Calculated using the formula
            %             for deriving the height of a right triangle given hypotenuse and tan A
            % @var sgn The sign of the slope of the object, to control direction
            var deltaX : real := SPEED / sqrt (m ** 2 + 1)
            var sgn : int := sign (m)
            
            % If m = 0 (horizontal line), make sgn = 1 as we multiply sgn with deltaX later on
            if sgn = 0 then
                sgn := 1
            end if
            
            % Add quantities onto coordinates
            x += sgn * round (deltaX)
            y += abs (round (m * deltaX))
        else
            % Object travelling vertically
            y += SPEED
        end if
    end updatePos
    
    % Returns whether an object with the given coordinates intersects with the current object
    %
    % @deferred
    % @param ox The x-coordinate of the intersecting object
    % @param oy The x-coordinate of the intersecting object
    %
    % @result `true` if the two objects intersect, otherwise `false`
    deferred fcn entersBoundingBox (ox : int, oy : int) : boolean
    
    % Returns the aliveness of the object
    %
    % @result `true` if the object is alive, otherwise `false`
    fcn isAlive : boolean
        result alive
    end isAlive
    
    % Returns if the object is banished (cannot be used again)
    %
    % @result `true` if the object is banished, otherwise `false`
    fcn isBanished : boolean
        result banished
    end isBanished
    
    % Draws the current object on the screen
    proc draw
        Sprite.SetPosition (sprite, x, y, true)
        Sprite.Show (sprite)
    end draw
    
    % Initializes the sprite for the current object
    %
    % @param SPRITE_NAME The filename of the sprite to use
    proc initialize (SPRITE_NAME : string)
        % @var spriteName The full directory path to the sprite
        % @var delayTime A dummy variable to store the delay between frames
        var spriteName : string := FOLDER_IMAGES + SPRITE_NAME
        var delayTime : int
        
        % Initialize array of sprites to hold all of the frames
        new sprites, Pic.Frames (spriteName)
        
        Pic.FileNewFrames (spriteName, sprites, delayTime)
        
        % Initial frame is starting sprite
        
        sprite := Sprite.New (sprites (1))
        
        spriteH := Pic.Height (sprites (1))
        spriteW := Pic.Width (sprites (1))
    end initialize
    
    % Creates the current object. Used as a wrapper for `ObjectClass.initialize`
    deferred proc create
    
    % Hides the current object from view
    proc hide
        % Only hide if the object is not banished
        if banished = false then
            Sprite.Hide (sprite)
        end if
    end hide
    
    % Sets the current object to be unalive. The object can still be used, but it may not be
    % interacted with.
    proc stab
        alive := false
    end stab
    
    % Kills the current object. This hides and frees the sprite as well as its resources.
    proc kill
        % Try not to beat a dead object
        if banished = false then
            Sprite.Hide (sprite)
            Sprite.Free (sprite)
            
            for i : 1 .. upper (sprites)
                Pic.Free (sprites (i))
            end for
                
            banished := true
        end if
        
        x := INFTY
        y := INFTY
        alive := false
        SPEED := 0
    end kill
    
    % Updates the position of the current object on the screen
    proc update
        self -> updatePos
        self -> draw
        
        % Destroy the object if it travels off the bounds of the screen
        if x > maxx + spriteW or x < -spriteW or y > maxy + spriteH or y < -spriteH then
            self -> kill
        end if
    end update
end ObjectClass

% Defines properties and methods of a blimp
class BlimpClass
    inherit ObjectClass
    export getDir, setDir,
        setCanvasBounds, setStartParams, setRandomStartParams,
        shoot
    
    TYPE := "BlimpClass"
    
    var cx : int
    var cy : int
    var dir : int
    
    var deathFit : boolean := false
    
    % Returns the direction that the blimp is travelling in
    %
    % @result &pdir
    proc getDir (var pdir : int)
        pdir := dir
    end getDir
    
    % Sets the direction that the blimp travels in
    %
    % @param pdir The desired direction
    proc setDir (pdir : int)
        dir := pdir
    end setDir
    
    % Sets the speed of the blimp based on its direction and a given speed
    % This is required as the blimp's movement/slope is independent of its direction, and we must
    % set the latter
    %
    % @override
    % @param pv The desired speed
    body proc setSpeed (pv : int)
        SPEED := dir * pv
    end setSpeed
    
    % @see ObjectClass.getFuturePos
    % This is required as the blimp's movement is independent of its slope - it will always travel
    % `SPEED` pixels horizontally, not diagonally
    body proc getFuturePos (t : int, var px : int, var py : int)
        if m < INFTY then
            px := x + t * SPEED
            py := round (m * t * SPEED) + y
        else
            px := x
            py := t * SPEED + y
        end if
    end getFuturePos
    
    % @see ObjectClass.updatePos
    % This is required as the blimp's movement is independent of its slope - it will always travel
    % `SPEED` pixels horizontally, not diagonally. As well, a special deathfit mode is activated
    % when the blimp is shot, so this has to be accounted for
    body proc updatePos
        if m < INFTY then
            x += SPEED
            y += round (m * SPEED)
        else
            y += SPEED
        end if
        
        if deathFit then
            % Activate deathfit mode
            Sprite.ChangePic (sprite, sprites (3))
            y -= PROJECTILE_SPEED div 2
        end if
    end updatePos
    
    % Set the bounds of the canvas that the blimp can travel in
    %
    % @param px The upper x-bound of the canvas
    % @param py The upper y-bound of the canvas
    proc setCanvasBounds (px : int, py : int)
        cx := px
        cy := py
    end setCanvasBounds
    
    % Sets the direction, starting coordinates and slope parameters of the blimp
    %
    % @param pdir The direction that the blimp will travel in
    % @param px The x-coordinate of the blimp
    % @param py The y-coordinate of the blimp
    % @param pm The slope of the blimp
    proc setStartParams (pdir : int, px : int, py : int, pm : real)
        self -> setDir (pdir)
        self -> setSpeed (BLIMP_SPEED)
        self -> setPos (px, py)
        self -> setSlope (pm)
    end setStartParams

    % Sets the starting parameters of the blimp randomly, with the y-coordinates within a given
    % range
    %
    % @param ymax The maximum distance from the top that blimps can start at
    % @param yrange The range of y-distances that the blimps can start at from `ymax`
    proc setRandomStartParams (ymax : int, yrange : int)
        % @var rdir A random direction for the blimp
        % @var rx A random x-coordinate for the blimp
        % @var ry A random y-coordinate for the blimp
        % @var rm A random slope for the blimp
        var rdir : int
        var rx : int
        var ry : int
        var rm : real

        % Set a random direction
        rdir := (-1) ** Rand.Int (0, 1)

        if rdir = 1 then
            % Blimp moves right, so it starts from the left side of the canvas
            rx := 0
        else
            % Blimp moves left, so it starts from the right side of the canvas
            rx := cx
        end if

        % Set a random y-coordinate within the range given as parameters
        ry := Rand.Int (cy - ymax - yrange, cy - ymax)
        
        % Set a random slope for the blimp
        rm := ((-1) ** Rand.Int (0, 1)) * Rand.Real
        
        % Flatten the trajectory of the blimp if its slope is too steep
        if abs (rm) > 0.1 then
            rm /= 6 % Flattens the slope
            
            % Prevent the blimp from going upwards (and possibly off the canvas) in this case
            if (rdir = 1 and rm > 0) or (rdir = -1 and rm < 0) then
                rm *= -1
            end if
        end if
        
        self -> setStartParams (rdir, rx, ry, rm)
    end setRandomStartParams

    % @see ObjectClass.entersBoundingBox
    % Checks if the object enters an ellipse following the curve of the blimp
    body fcn entersBoundingBox
        result ((ox - x) / (spriteW / 2)) ** 2 + ((oy - y) / (spriteH / 2)) ** 2 <= 1
    end entersBoundingBox
    
    % @see ObjectClass.create
    body proc create
        % Different starting positions and sprites depending on the direction of the blimp
        if dir = 1 then
            self -> initialize (SPRITE_BLIMP_RIGHT)
            self -> setPos (x - spriteW div 2, y)
        else
            self -> initialize (SPRITE_BLIMP_LEFT)
            self -> setPos (x + spriteW div 2, y)
        end if
    end create
    
    % Defines the behaviour of the blimp when it is shot
    %
    % @param &score The current score of the game
    %
    % @result &score An increased score for the game
    proc shoot (var score : int)
        deathFit := true
        
        % Display a HUD as a special effect
        fork hudIncScore (x, y)
        
        score += 1000
        
        % Prevent the blimp from being interacted with, but still allow for its usage
        self -> stab
    end shoot
end BlimpClass

% Define a type for the blimp so it can be used in arrays
type Blimp : ^BlimpClass

% Defines properties and methods of a projectile
class ProjectileClass
    inherit ObjectClass
    
    TYPE := "ProjectileClass"
    
    % @see ObjectClass.entersBoundingBox
    body fcn entersBoundingBox
        result ox = x and oy = y
    end entersBoundingBox
    
    % @see ObjectClass.create
    body proc create
        self -> initialize (SPRITE_PROJECTILE)
    end create
end ProjectileClass

% Define a type for the projectile so it can be used in arrays
type Projectile : ^ProjectileClass

% Defines properties and methods of a bomb
class BombClass
    inherit BlimpClass
    
    TYPE := "BombClass"
    
    % @see ObjectClass.entersBoundingBox
    body fcn entersBoundingBox
        result (ox - x) ** 2 + (oy - y) ** 2 < spriteW ** 2 / 4
    end entersBoundingBox
    
    % @see BlimpClass.create
    body proc create
        self -> initialize (SPRITE_BOMB)
        
        if dir = 1 then
            self -> setPos (x - spriteW div 2, y)
        else
            self -> setPos (x + spriteW div 2, y)
        end if
    end create
    
    % @see BlimpClass.shoot
    body proc shoot (var score : int)
        deathFit := true
        % fork hudDecLives (x, y)
        
        self -> stab
    end shoot
end BombClass

% Define a type for the bomb so it can be used in arrays
type Bomb : ^BombClass
