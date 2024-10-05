-- Modo de utilização:

-- Criar uma nova editBox

EditBox:new (index, text, number, max, font, size, masked)

-- Renderizar a editBox

addEventHandler ('onClientRender', root,
    function ()
        EditBox:draw (index, x, y, w, h, color_not_selected, color_selected)
    end
)

-- Destruir 

EditBox:destroy ();

-- Retornar texto atual 

EditBox:getText (index);

-- Retornar texto secundario 

EditBox:getText_2 (index);

-- Setar texto 

EditBox:setText (index, text);

-- Exemplo

EditBox:new ('teste', 'Teste', false, 100, 'default', 2, false)

addEventHandler ('onClientRender', root,
    function ()
        EditBox:draw ('teste', 100, 100, 300, 100, tocolor (0, 0, 0, 150), tocolor (0, 0, 0, 255))
    end
)


local text = EditBox:getText ('teste')

iprint (text)
        
EditBox:setText ('teste', 'Olá mundo!')

local actual = EditBox:getText ('teste')

iprint (actual)

EditBox:destroy ()
