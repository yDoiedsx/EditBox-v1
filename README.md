-- Modo de utilização:

-- Criar uma nova editBox

EditBox:new (index, text, number, max, font, size, masked)

-- Renderizar a editBox

addEventHandler ('onClientRender', root,
    function ()
        EditBox:draw (index, x, y, w, h, color_not_selected, color_selected)
    end
)

-- Exemplo

EditBox:new ('teste', 'Teste', false, 100, 'default', 2, false)

addEventHandler ('onClientRender', root,
    function ()
        EditBox:draw ('teste', 100, 100, 300, 100, tocolor (0, 0, 0, 150), tocolor (0, 0, 0, 255))
    end
)
