/**
 * JSON.tu --- Parses rudimentary JSON files. Does not support arrays or nested objects.
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
module JSON
    export Pair, parsePair, toArray, fromArray
    
    % Defines an associative pair of a key and a value
    type Pair:
    record
        key : string
        value : string
    end record
    
    % Parses a string into a Pair type
    %
    % @param d The data to parse
    % @param &p A pair to hold the parsed values
    %
    % @result &p A pair containing the parsed key and value
    proc parsePair (d : string, var p : Pair)
        % @var mode The mode to parse. 0 = before key, 1 = parsing key, 2 = end key/before value,
            %       3 = parsing value (string), 4 = escape character, 5 = parsing value (number)
        % @var lastMode The last parsed mode. Used for escape characters
        % @var k A temporary key value
        % @var v A temporary value value
        var mode : int := 0
        var lastMode : int
        var k : string := ""
        var v : string := ""
        
        % Lexically parse the data
        for i : 1 .. length (d)
            % @var ch The currently iterated character
            var ch : string := d (i)
            
            case ch of
            label "{", "}":
                % Start/end of JSON object
                if mode ~= 1 or mode ~= 3 then
                    exit
                end if
            label "\\":
                % Escape next character
                if mode = 1 or mode = 3 then
                    % Turn on escaping
                    lastMode := mode
                    mode := 4
                elsif mode = 4 then
                    % Ignore parsing of character
                    mode := lastMode
                else
                    % Syntax error
                        Error.Halt ("Syntax error: Unexpected '\\' in column " + intstr (i) + " of data.")
                end if
            label "\"":
                % Delimit key/value values
                if mode = 4 then
                    % Ignore parsing of character
                    mode := lastMode
                elsif 0 <= mode and mode <= 2 then
                    % Transitioning between modes; since modes are sequential in terms of reading
                    % JSON from left-to-right, this works
                    %
                    % 0 -> 1 equiv before key -> key
                    % 1 -> 2 equiv key -> end key
                    % 2 -> 3 equiv before value -> value
                    mode += 1
                elsif mode = 3 then
                    % End of value
                    mode := 0
                else
                    % Syntax error
                        Error.Halt ("Syntax error: Unexpected '\"' in column " + intstr (i) + " of data.")
                end if
            label ":":
                % Delimit key and value
                if mode = 0 or mode = 5 then
                    % Syntax error
                        Error.Halt ("Syntax error: Unexpected ':' in column " + intstr (i) + " of data.")
                end if
            label ",":
                % Delimit pairs
                if mode = 5 then
                    % End of pair
                    mode := 0
                elsif mode = 0 or mode = 2 then
                    % Syntax error
                        Error.Halt ("Syntax error: Unexpected '\"' in column " + intstr (i) + " of data.")
                end if
            label:
                % All non-special characters
                if mode = 2 and ("0" <= ch and ch <= "9") or ch = "-" then
                    % Parse unquoted numbers
                    mode := 5
                end if
            end case
            
            % Add character to either key or value depending on mode
            if mode = 1 then
                k += ch
            elsif mode = 3 or mode = 5 then
                v += ch
            end if
        end for
            
        % Trim leading quotation mark from key
        if length (k) > 0 then
            k := k (2 .. *)
        end if
        
        % Trim leading quotation mark from value, if it is a string
        if length (v) > 0 and v (1) = "\"" then
            v := v (2 .. *)
        end if
        
        % Modify key and value of passed-in pair
        p.key := k
        p.value := v
    end parsePair
    
    % Turns a JSON object into an array of pairs
    %
    % @param d The data to parse
    % @param &arr An array of pairs, with known bounds that equal the number of pairs in the object
    %
    % @result &arr An array of resolved pairs
    proc toArray (d : string, var arr : array 1 .. * of Pair)
        % @var mode The mode to parse. 0 = not parsing, 1 = parsing, 2 = escape character
        % @var lastMode The last parsed mode. Used for escape characters
        % @var ind The index of the given array to write to
        % @var a A temporary array of strings (not Pairs) to parse into a Pair
        var mode : int := 0
        var lastMode : int
        var ind : int := 1
        
        var a : array 1 .. upper (arr) of string
        
        % Initialize each value in an array
        for j : 1 .. upper (arr)
            a (j) := ""
        end for
            
        % Lexically parse JSON object
        for i : 1 .. length (d)
            % @var ch The currently iterated character
            var ch : string := d (i)
            
            case ch of
            label "{", "}":
                % Start/end of JSON object
                if mode = 0 then
                    ch := ""
                end if
            label "\\":
                % Escape next character
                if mode = 1 then
                    % Turn on escaping
                    lastMode := mode
                    mode := 2
                elsif mode = 2 then
                    % Ignore parsing of character
                    mode := lastMode
                end if
            label "\"":
                % Delimit key/value values
                if mode = 2 then
                    % Ignore parsing of character
                    mode := lastMode
                elsif mode = 1 then
                    % End of value
                    mode := 0
                end if
            label ",":
                % Delimit pairs
                if mode = 0 then
                    ind += 1
                    ch := ""
                end if
            label:
                % Non-special character
            end case
            
            % Append character to `a`
            a (ind) += ch
        end for
            
        % Check array bounds
        if upper (arr) ~= ind then
            Error.Halt ("Error: Given array and given data do not have an equal number of pairs")
        end if
        
        % Parse string data into Pairs
        for j : 1 .. ind
            parsePair (a (j), arr (j))
        end for
    end toArray
    
    % Turns an array into a JSON object
    %
    % @var a An array of Pairs to be converted
    % @var &out A string representing the converted JSON object
    %
    % @result &out A valid JSON object, in string form
    proc fromArray (a : array 1 .. * of Pair, var out : string)
        % Initialize object
        out := "{\n"
        
        % Iterate over pairs
        for i : 1 .. upper (a)
            out += "    "                    % Add indentation
            out += "\"" + a (i).key + "\""   % Add key
            out += ": "                      % Add key/value delimiter
            out += "\"" + a (i).value + "\"" % Add value
            
            % JSON specification does not allow for trailing commas in the last pair, so we only
            % add commas if the pair is not the last
            if i < upper (a) then
                out += ",\n"
            else
                out += "\n"
            end if
        end for
            
        % Close object
        out += "}"
    end fromArray
end JSON
