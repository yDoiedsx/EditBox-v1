local screen_w, screen_h = guiGetScreenSize ();

EditBox = {};
EditBox.__ = EditBox;

function EditBox:new (index, text, number, max, font, size, masked)
    if not self.data[index] then
        if (not masked) then
            masked = false;
        end

        self.data[index] = {index = index, string = 1, text = '', text_2 = text, pos = {0, 0, 0, 0}, number = number, max = max, font = font, size = size, masked = masked};
    end
end;

function EditBox:draw (index, x, y, w, h, color, color_2)
    if (not self.data[index]) then
        return false;
    end

    local data = self.data[index]

    h = h + 15

    data.pos = {x, y, w, h}

    local text = data.text

    if (data.masked == true) then
        text = data.text ~= data.text_2 and string.gsub (data.text, '.', '*') or data.text
    end
    
    local string = string.sub (text, 1, data.string);
    local width = dxGetTextWidth (string, data.size, data.font);

    local textWidth = dxGetTextWidth (text, data.size, data.font);
    
    local side = ((x + width) > (x + w) and 'right' or 'left');

    if (width > w and width < textWidth) then
        text = string.sub (text, 1, data.string)
    end

    if (data.text == '') then
        dxDrawText (data.text_2, x, y, w, h, color, data.size, data.font, side, 'top', true, false, true)
    else
        dxDrawText (text, x, y, w, h, data.text == data.text_2 and color or color_2, data.size, data.font, side, 'top', true, false, true)
    end

    if (self.selected == index) then
        local size = dxGetFontHeight (data.size, data.font);
        
        if (self.lctrl) then
            local lcrtl_size = math.min(w, textWidth)

            dxDrawRectangle (
                x - 2, 
                y, lcrtl_size + 1, 
                size, tocolor(89, 154, 248, 100), true
            )
        end
        
        if (not self.write) then
            if (self.type == 'in') then
                self.animation = math.min (1, self.animation + 0.018)

                if (self.animation >= 1) then
                    self.type = 'out'
                end
            else
                self.animation = math.max (self.animation - 0.018, 0.1)
                
                if (self.animation <= 0.1) then
                    self.type = 'in'
                end
            end
        end

        local rectanglePos = math.min (x + w, x + width)
        
        if (data.text == data.text_2) then
            rectanglePos = math.min (x, x + width)
        end

        dxDrawRectangle (
            rectanglePos, 
            y, 1, 
            size, tocolor(255, 255, 255, self.animation * 255), true
        )
    end

    return true;
end;

function EditBox:click (b, s)
    if (not b == 'left') then
        return false;
    end

    if (not s == 'down') then
        return false;
    end

    if (self.selected) then
        self.selected = false;
    end

    for _, data in pairs (self.data) do
        if (self.cursor (data.pos[1], data.pos[2], data.pos[3], data.pos[4])) then
            self.lctrl = false
            self.write = false

            data.string = string.len (data.text)

            self.selected = data.index
        end
    end
end;

function EditBox:key (key, press)
    if (not press) then
        return false;
    end

    if (not self.selected) then
        return false;
    end

    local data = self.data[tostring (self.selected)]

    if (not data) then
        return false;
    end
    
    if (key == 'backspace') then
        if (not self.lctrl) then
            if (data.text ~= '' and data.text ~= data.text_2) then
                if (data.string > 0) then
                    data.text = string.sub(data.text, 1, data.string - 1)..string.sub (data.text, data.string + 1)

                    data.string = data.string - 1
                end
            end
        else
            data.text = data.text_2

            data.string = 0
            self.lctrl = false
        end
    end
    
    if (key == 'arrow_l') then
        if (data.string > 0) then
            data.string = data.string - 1
        end
    end

    if (key == 'arrow_r') then
        local max = string.len (data.text)

        if (data.string < max) then
            data.string = data.string + 1
        end
    end

    if (key == 'a') then
        if (not getKeyState ('lctrl')) then
            return false;
        end

        self.lctrl = true
    end

    if (key == 'c') then
        if (not self.lctrl) then
            return false;
        end
        
        setClipboard (data.text)
    end
end;

function EditBox:character (character)
    if (not self.selected) then
        return false;
    end

    local data = self.data[tostring (self.selected)]

    if (not data) then
        return false;
    end

    if (data.number) then
        if (not tonumber (character)) then
            return false;
        end
    end

    local actual = string.len (data.text)

    if (actual >= data.max) then
        return false;
    end

    if (data.text == '' or self.lctrl or data.text == data.text_2) then
        data.text = character

        data.string = 1
        self.lctrl = false;
    else
        if (data.string ~= actual) then
            data.text = string.sub(data.text, 1, data.string)..character..string.sub (data.text, data.string + 1)
        else
            data.text = data.text..character
        end

        data.string = data.string + 1
    end

    if (not self.write) then
        self.write = true

        setTimer (
            function ()
                if (self.write) then
                    self.write = false
                end
            end, 1000, 1
        )
    end
end;

function EditBox:paste (text)
    if (not self.selected) then
        return false;
    end

    local data = self.data[tostring (self.selected)]

    if (not data) then
        return false;
    end

    if (data.number) then
        if (not tonumber (text)) then
            return false;
        end
    end

    local actual = string.len (data.text) + string.len (text)

    if (actual >= data.max) then
        return false;
    end

    if (data.text == '' or self.lctrl or data.text == data.text_2) then
        data.text = text

        data.string = string.len (text)
        self.lctrl = false;
    else
        if (data.string ~= actual) then
            data.text = string.sub(data.text, 1, data.string)..text..string.sub (data.text, data.string + 1)
        else
            data.text = data.text..character
        end

        data.string = data.string + string.len (text)
    end
end;

function EditBox:getText (index)
    if (not self.data[index]) then
        return ''
    end
    
    return self.data[index].text
end;

function EditBox:setText (index, text)
    if (not self.data[index]) then
        return false;
    end
    
    self.data[index].text = text

    return true;
end;

function EditBox:destroy ()
    self.data = {};

    return self.data;
end;

function EditBox:constructor ()
    self.data = {};

    self.type = 'in';

    self.hover = false;
    self.lctrl = false;
    self.write = false;
    self.selected = false;

    self.tick = getTickCount();

    self.animation = 0;

    self.cursor = function (x, y, w, h)
        local cx, cy = getCursorPosition ()

        cx, cy = cx * screen_w, cy * screen_h

        if (cx > x and cx < (x + w) and cy > y and cy < (y + h)) then
            return true;
        end

        return false;
    end

    addEventHandler ('onClientClick', root,
        function (b, s)
            return self:click (b, s)
        end
    );

    addEventHandler ('onClientKey', root,
        function (...)
            return self:key (...)
        end
    );

    addEventHandler ('onClientCharacter', root,
        function (character)
            return self:character (character)
        end
    );

    addEventHandler ('onClientPaste', root,
        function (paste)
            return self:paste (paste)
        end
    );

    return self;
end;

EditBox:constructor (...)