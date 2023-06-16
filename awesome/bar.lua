
local power = require("widget-drymnz.power")
local info = require("widget-drymnz.informacion-sistema")

function throw_bar(awful,set_wallpaper,tasklist_buttons,wibox,gears,taglist_buttons)

    awful.screen.connect_for_each_screen(function(s)
        -- Fondo de pantalla
        set_wallpaper(s)
        -- Cada pantalla tiene su propia tabla de etiquetas.
        awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s, awful.layout.layouts[1])
        -- Cree un widget de cuadro de imagen que contendrá un icono que indica qué diseño estamos usando.
        -- Necesitamos un cuadro de diseño por pantalla.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(awful.button({}, 1, function()
            awful.layout.inc(1)
        end), awful.button({}, 3, function()
            awful.layout.inc(-1)
        end), awful.button({}, 4, function()
            awful.layout.inc(1)
        end), awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)))
        -- Crear un widget de lista de etiquetas
        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            style = {
                bg_empty = tono_georgias_3, -- cuando esta vacio la mesa de trabajo
                fg_empty = tono_georgias_5,
                bg_focus = tono_georgias_1, -- cuando esta enfoca/tu posicion la mesa de trabajo
                fg_focus = tono_georgias_4,
                bg_occupied = tono_verde_marino, -- cuando esta ocupada pero no esta seleccionada la mesa de trabajo
                fg_occupied = tono_georgias_3,
            },
            buttons = taglist_buttons
        }
        -- Crear un widget de lista de tareas, el listado de programas abiertos en la mesa de trabajo actual
        s.mytasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            style = {
                bg_normal = tono_georgias_2, 
                bg_focus = tono_georgias_4,
                disable_task_name = true, -- desactiva el nombre de la ventana
                border_width = 1,
                border_color = tono_georgias_2,
                shape = gears.shape.rounded_bar
            },
            layout = { -- etiqueta de la ventana mostrada
                spacing_widget = {
                    {
                        forced_width = 5,
                        forced_height = 24,
                        thickness = 1,
                        color = tono_georgias_2,
                        widget = wibox.widget.separator
                    },
                    valign = "center",
                    halign = "center",
                    widget = wibox.container.place
                },
                spacing = 3,
                layout = wibox.layout.fixed.horizontal
            },
            buttons = tasklist_buttons
        }
        -- crear la barra de tareas / estados (https://awesomewm.org/apidoc/popups_and_bars/awful.wibar.html)
        s.mywibox = awful.wibar({
            position = "top",
            border_width=1,--borde
            border_color=tono_verde_marino,--color de borde
            screen = s,
            bg = tono_azul_cielo, --Tono de la barra
            fg = tono_verde_marino, --tono del menu derecho
            width ="70%",
            height =25,
            shape=gears.shape.rounded_rect
        })
        -- Add widgets to the wibox
        s.mywibox:setup{
            layout = wibox.layout.align.horizontal,
            { -- iquierda widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher, --menu awesome
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Widget medio listado de aplicaciones abiertas
            -- {{{ Volume Indicator
            { -- derecha widgets
                layout = wibox.layout.fixed.horizontal,
                -- mykeyboardlayout, el tecldo 
                wibox.widget.systray {
                }, 
                -- las terea en segundo plano
                wibox.widget.textclock('%B %d -- %H:%M --'), -- Crear un widget de reloj de texto (https://awesomewm.org/apidoc/widgets/wibox.widget.textclock.html)
                -- informacino de sistema  
                info(4),       
                info(3),
                info(1),
                info(2),
                power,
                --default,
                --logout_menu_widget(),
                s.mylayoutbox, -- este es el de como sera ordenado las ventanas    
                  
            }
        }
    end)

    
    
end
