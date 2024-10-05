-- Criar --

EditBox:new ('teste', 'Teste', false, 100, 'default', 2, false)

-- Renderizar --

addEventHandler ('onClientRender', root,
    function ()
        EditBox:draw ('teste2', 100, 300, 300, 100, tocolor (0, 0, 0, 150), tocolor (0, 0, 0, 255))
    end
)
