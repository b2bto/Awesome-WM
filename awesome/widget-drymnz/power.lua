--lo siguiente lo aprendi intrepretando el siguiete repositorio
--https://github.com/streetturtle/awesome-wm-widgets/tree/master/logout-menu-widget
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- variable de HOME
local HOME = os.getenv('HOME')
local ICON_DIR = HOME .. '/.config/awesome/icons/'

--todo un widget tiene cosas primitias 
--(https://awesomewm.org/doc/api/classes/wibox.container.background.html#wibox.container.background.bgimage)
local texto = "-POWER-"

local power_menu = wibox.widget {
    ---lo que va a contener
    {
       {
        image = ICON_DIR .. 'power_w.svg',
        resize = true,
        widget = wibox.widget.imagebox,
    },
    margins = 4,
    layout = wibox.container.margin
    },
    --parametros
    --dibujarlo con una forma https://awesomewm.org/doc/api/libraries/gears.shape.html
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 4)
    end,
    widget = wibox.container.background,
}

--Muetra una ventana personalizada 
--(https://awesomewm.org/doc/api/classes/awful.popup.html)
menu = awful.popup {
    ontop = true,
    visible = false,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 4)
    end,
    border_width = 1,
    border_color = beautiful.bg_focus,
    maximum_width = 400,
    offset = { y = 5 },
    widget = {}
}
--Las filas
--rows = { layout = wibox.layout.fixed.vertical }
--local function worker(user_args)
local rows = { layout = wibox.layout.fixed.horizontal }
local args = user_args or {}
local font = args.font or beautiful.font
local onlogout = args.onlogout or function () awesome.quit() end
local onlock = args.onlock or function() awful.spawn.with_shell("i3lock") end
local onreboot = args.onreboot or function() awful.spawn.with_shell("reboot") end
local onsuspend = args.onsuspend or function() awful.spawn.with_shell("systemctl suspend") end
local onpoweroff = args.onpoweroff or function() awful.spawn.with_shell("shutdown now") end



--Listado de acciones
--local menu_items = {
--    { name = 'Cerrar Seccion', command = function () awesome.quit() end },
--    { name = 'Bloquear',command = function() awful.spawn.with_shell("i3lock") end },
--    { name = 'Reiniciar', command = function() awful.spawn.with_shell("reboot") end },
--    { name = 'Apagar',command = function() awful.spawn.with_shell("shutdown now") end },
--}
local menu_items = {
    { name = 'Log out', icon_name = 'log-out.svg', command = onlogout },
    { name = 'Lock', icon_name = 'lock.svg', command = onlock },
    { name = 'Reboot', icon_name = 'refresh-cw.svg', command = onreboot },
    { name = 'Suspend', icon_name = 'moon.svg', command = onsuspend },
    { name = 'Power off', icon_name = 'power.svg', command = onpoweroff },
}

--La accion del listado
for _, item in ipairs(menu_items) do
    local row = wibox.widget {
            {
                {
                    {
                        image = ICON_DIR .. item.icon_name,
                        resize = false,
                        widget = wibox.widget.imagebox
                    },
                    {
                        text = item.name,
                        font = font,
                        widget = wibox.widget.textbox
                    },
                    spacing = 12,
                    layout = wibox.layout.fixed.horizontal
                },
                margins = 8,
                layout = wibox.container.margin
            },
            bg = beautiful.bg_normal,
            widget = wibox.container.background
        }
--    local row = wibox.widget {
--        {
--            {
--                text = item.name,
--                font = beautiful.font,
--                widget = wibox.widget.textbox
--            },
--            margins=10,
--            fg = "#000000",
--            bg = "#e6e6e6",
--            shape = function(cr, width, height)
--                gears.shape.rounded_rect(cr, width, height, 4)
--            end,
--            layout = wibox.container.background
--        },
--        margins = 5,
--        color = "#000000",
--        layout = wibox.container.margin
--    }

    
    --ejecutar la accion con el click
    row:buttons(
        awful.util.table.join(
            awful.button(
                {}, 
                1, 
                function()
                    menu.visible = not menu.visible
                    item.command()
                end
            )
        )
    )

    table.insert(rows, row)
end

menu:setup(rows)

power_menu:buttons(
    awful.util.table.join(
        awful.button(
            {}, 1, 
            function()
                if menu.visible then
                    menu.visible = not menu.visible
                else
                    menu:move_next_to(mouse.current_widget_geometry)
                end
            end
        )
    )
)

return power_menu
