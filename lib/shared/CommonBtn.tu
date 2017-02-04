/**
 * CommonBtn.tu --- Creates rudimentary styled buttons for use
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

unit
module CommonBtn
    export all
    
    % Defines the properties of a button
    %
    % @field text The label of the button
    % @field x The x-position of the button
    % @field y The y-position of the button
    % @field width The width of the button
    % @field height The height of the button
    % @field bgClr The background colour of the button
    % @field fgClr The foreground colour of the button
    % @field font The font to display the text in
    % @field centre Whether to centre the button on the x and y positions or not
    type Btn:
    record
        text : string
        x : int
        y : int
        width : int
        height : int
        bgClr : int
        fgClr : int
        font : int
        centre : boolean
        selected : boolean
    end record
    
    % Initialize a button's properties
    %
    % @var &btn The button to initialize
    % @var text The label of the button
    % @var x The x-position of the button
    % @var y The y-position of the button
    % @var width The width of the button
    % @var height The height of the button
    % @var bgClr The background colour of the button
    % @var fgClr The foreground colour of the button
    % @var font The font to display the text in
    % @var centre Whether to centre the button on the x and y positions or not
    proc initBtn (var btn : Btn, text : string, x : int, y : int, width : int, height : int, bgClr : int, fgClr : int, font : int, centre : boolean)
        btn.text := text
        btn.x := x
        btn.y := y
        btn.width := width
        btn.height := height
        btn.bgClr := bgClr
        btn.fgClr := fgClr
        btn.font := font
        btn.centre := centre
        btn.selected := false
    end initBtn
    
    % Draw a button on the screen
    %
    % @var btn The button to draw
    proc drawBtn (var btn : Btn)
        % @var h The height of the button's font
        % @var ascent The ascent of the button's font
        % @var descent The descent of the button's font
        % @var i The internal leading of the button's font
        var h : int
        var ascent : int
        var descent : int
        var i : int
        
        % Get the various values defined above for the font, so that the text can be centred in
        % the button
        Font.Sizes (btn.font, h, ascent, descent, i)
        
        if btn.centre then
            % Centre the button
            Draw.FillBox (btn.x - btn.width div 2, btn.y - btn.height div 2, btn.x + btn.width div 2, btn.y + btn.height div 2, btn.bgClr)
            Font.Draw (btn.text, btn.x - Font.Width (btn.text, btn.font) div 2, btn.y - (ascent - descent) div 2, btn.font, btn.fgClr)
        else
            Draw.FillBox (btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, btn.bgClr)
            Font.Draw (btn.text, btn.x + (btn.width - Font.Width (btn.text, btn.font)) div 2, btn.y + (btn.height - (ascent - descent)) div 2, btn.font, btn.fgClr)
        end if
        
        btn.selected := false
    end drawBtn
    
    % Draw a selected button on the screen (fg/bg colours inverted, pointer added)
    %
    % @var btn The button to draw
    proc selectBtn (var btn : Btn)
        % @var h The height of the button's font
        % @var ascent The ascent of the button's font
        % @var descent The descent of the button's font
        % @var i The internal leading of the button's font
        var h : int
        var ascent : int
        var descent : int
        var i : int
        
        % Get the various values defined above for the font, so that the text can be centred in
        % the button
        Font.Sizes (btn.font, h, ascent, descent, i)
        
        if btn.centre then
            % Centre the button
            Draw.FillBox (btn.x - btn.width div 2, btn.y - btn.height div 2, btn.x + btn.width div 2, btn.y + btn.height div 2, btn.fgClr)
            Font.Draw (btn.text, btn.x - Font.Width (btn.text, btn.font) div 2, btn.y - (ascent - descent) div 2, btn.font, btn.bgClr)
            % Draw a pointer to identify this button as the currently selected one
            Font.Draw (">", btn.x - btn.width div 2 + 10, btn.y - (ascent - descent) div 2, btn.font, btn.bgClr)
        else
            Draw.FillBox (btn.x, btn.y, btn.x + btn.width, btn.y + btn.height, btn.fgClr)
            Font.Draw (btn.text, btn.x + (btn.width - Font.Width (btn.text, btn.font)) div 2, btn.y + (btn.height - (ascent - descent)) div 2, btn.font, btn.bgClr)
            % Draw a pointer to identify this button as the currently selected one
            Font.Draw (">", btn.x + 10, btn.y + (btn.height - (ascent - descent)) div 2, btn.font, btn.bgClr)
        end if
        
        % Define the button as selected
        btn.selected := true
    end selectBtn
end CommonBtn