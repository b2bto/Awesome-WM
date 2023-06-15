-- IMPORTACIONES O REQUERIMIENTOS DE LA EJECUCION
-- documentacion (https://awesomewm.org/apidoc/index.html)
pcall(require, "luarocks.loader")
-- Biblioteca impresionante estándar del entorno
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Biblioteca de widgets y diseños
local wibox = require("wibox")
-- Biblioteca de manejo de temas
local beautiful = require("beautiful")
-- Biblioteca de notificaciones
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Habilite el widget de ayuda de teclas rápidas para VIM y otras aplicaciones
-- cuando se abre un cliente con un nombre coincidente:
require("awful.hotkeys_popup.keys")
-- colores para modificar
require("color")
-- portar para la funcion de bar (cargar la barra)
require("bar")
-- importar para cargar lo comandos de tecla global
require("keys")
--Seccion de intento por activar tecla fn

-- NOTA COLOCAR LA RUTA DEL LA IMAGEN /home/{usario}/.config/awesome/wallpaper/XXXXXjpg"

url_wallpaper = "/home/liun1x/.config/awesome/wallpaper/54396-pc.jpg"

-- Sources:
-- * https://wiki.archlinux.org/index.php?oldid=265165#Random_Background_Image
-- * https://wiki.archlinux.org/title/Special:Diff/265909
-- * https://www.reddit.com/r/awesomewm/comments/3r01p1/

-- {{{ Function definitions

-- scan directory, and optionally filter outputs
function scandir(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return true end
    end
    print(filter)
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end

-- }}}

-- configuration - edit to your liking
wp_timeout  = 350
wp_path = "/home/liun1x/.config/awesome/wallpaper/"
wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end
wp_files = scandir(wp_path, wp_filter)

-- initialize the random generator
math.randomseed(os.time())

-- setup the timer
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()

  -- get random index
  local wp_index = math.random( 1, #wp_files)

  -- set wallpaper to current index for all screens
  for s = 1, screen.count() do
    gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
  end

  -- stop the timer (we don't need multiple instances running at the same time)
  wp_timer:stop()

  --restart the timer
  wp_timer.timeout = wp_timeout
  wp_timer:start()
end)

-- initial start when rc.lua is first run
wp_timer:start()

-- {{{ Manejo de errores
-- Compruebe si Awesome encontró un error durante el inicio y volvió a
-- otra configuración (Este código solo se ejecutará para la configuración alternativa)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end
-- Manejar errores de tiempo de ejecución después del inicio
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}
-- {{{ Definiciones de variables
-- Definir el fondo de pantalla por defecto.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
-- variables globales
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

----Desde aqui mis atajos 
browser = "firefox"
browserG = "google-chrome-stable"
vscode = "code"
ink = "inkscape"
gimp = "gimp"
krita = "krita"
archivos = "thunar"


-- Tecla de modo predeterminada.
-- Usualmente, Mod4 es la tecla con un logo entre Control y Alt.
-- Esta definicio de Mod4 se refiere a la tecla de inicio del teclado
-- tambien conocida como tecla de windows
modkey = "Mod4"
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = 
    { 
        -- puede agregar mas si lo desea, mas informacion (https://awesomewm.org/apidoc/libraries/awful.layout.html)
    awful.layout.suit.floating, -- ventana flotable
    awful.layout.suit.fair, -- awful.layout.suit.spiral,-- forma de un caracol
    }
-- }}}
-- {{{ Menú
-- Crear un widget de inicio y un menú principal
myawesomemenu = {
    {"hotkeys", function()
    hotkeys_popup.show_help(nil, awful.screen.focused())end}, 
{"manual", terminal .. " -e man awesome"},
{"edit config", editor_cmd .. " " .. awesome.conffile},
{"restart", awesome.restart},
}
--Listado de app del menu
beautiful.menu_height = 20
beautiful.menu_width = 200

beautiful.menu_border_color	= tono_lila_dos
beautiful.menu_border_width	 = 1

beautiful.menu_bg_normal = tono_georgias_3 --fondo
beautiful.menu_fg_normal = tono_georgias_4 -- letras
beautiful.menu_bg_focus =  tono_georgias_2 -- fodo sseccion eleccionada
beautiful.menu_fg_focus = tono_georgias_4 

navegadores_internet = {
    {"Fire-Fox", "firefox"},
    {"Google", "google-chrome-stable"}
}
Developer = {
    {"Visual Code", "code"},
    {"Kitty", "kitty"}
}

mymainmenu = awful.menu({
    items = {
        {"awesome", myawesomemenu, "/home/liun1x/.config/awesome/icons/awesome-icon.png"}, -- icono Awesome beautiful.awesome_icon
        {"Navegador", navegadores_internet, "imgLogo"},
        {"Developer", Developer},
        {"open terminal", terminal},
        {"Archivos", archivos}}
})
--modificar el icono del menu
mylauncher = awful.widget.launcher({
    image = "/home/liun1x/.config/awesome/icons/awesome-icon.png",
    menu = mymainmenu
})
-- Indicador de mapa de teclado y conmutador
mykeyboardlayout = awful.widget.keyboardlayout()
-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
-- Crear un wibox para cada pantalla y agregarlo
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
    t:view_only()
end), awful.button({modkey}, 1, function(t)
    if client.focus then
        client.focus:move_to_tag(t)
    end
end), awful.button({}, 3, awful.tag.viewtoggle), awful.button({modkey}, 3, function(t)
    if client.focus then
        client.focus:toggle_tag(t)
    end
end), awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
end), awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
end))
local tasklist_buttons = gears.table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c:emit_signal("request::activate", "tasklist", {
            raise = true
        })
    end
end), awful.button({}, 3, function()
    awful.menu.client_list({
        theme = {
            width = 250
        }
    })
end), awful.button({}, 4, function()
    awful.client.focus.byidx(1)
end), awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
end))
-- Distancia entre laterales
beautiful.useless_gap = 5
awful.screen.connect_for_each_screen(function(s)
    s.padding = 6 -- entre la ventan aun siendo no siendo tile
end)
-- Manjador de walllpaper
local function set_wallpaper(s)
    -- Si encontro la imagen del fondo de pantalla
    local f=io.open(url_wallpaper,"r") 
    if f~=nil 
    then 
        io.close(f) 
        gears.wallpaper.maximized(url_wallpaper, s, true)-- un archivo formato imagen
    else 
        if beautiful.wallpaper then
            -- Fondo de pantalla
            local wallpaper = beautiful.wallpaper
            -- Si encontro la imagen del fondo de pantalla por defecto
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)-- un archivo formato imagen
        end
        -- NOTA : En este punto se coloca el fondo de pantalla
        gears.wallpaper.set("000000AA")--un color solido
    end
end
-- Vuelva a configurar el fondo de pantalla cuando cambie la geometría de una pantalla (por ejemplo, una resolución diferente)
screen.connect_signal("property::geometry", set_wallpaper)
-- }}}
-- funcion de configuracion de barra (archivo bar.lua)
throw_bar(awful, set_wallpaper, tasklist_buttons, wibox, gears, taglist_buttons)
-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function()
    mymainmenu:toggle()
end), 
    awful.button({}, 4, 
    awful.tag.viewnext), 
    awful.button({}, 5, 
    awful.tag.viewprev)))
-- }}}
clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
end), awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.move(c)
end), awful.button({modkey}, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.resize(c)
end))
-- }}}
-- cargar la configuracion de teclas / atajo de teclas 
relizar_kyes(modkey, awful, hotkeys_popup, gears,terminal)
-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Normas a aplicar a nuevos clientes (a través de la señal "gestionar").).
awful.rules.rules = { --- Todos los clientes coincidirán con esta regla.
{
    -- propiedades de la nueva ventana
    rule = {},
    properties = {
        border_color = color_naranja_one,
        focus = awful.client.focus.filter,
        border_width = "2",
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    }
},
{
}, 
{-- Agregar barras de título a clientes y cuadros de diálogo normales
    rule_any = {
        type = {"normal", "dialog"}
    },
    properties = {
        titlebars_enabled = false -- oculatar la barra de las ventanas
    }
} 
}
-- }}}


-- {{{ Señales
-- Función de señal para ejecutar cuando aparece un nuevo cliente.
client.connect_signal("manage", function(c)
    -- Establecer las ventanas en el esclavo,
    -- es decir, ponerlo al final de otros en lugar de configurarlo como maestro.
    -- si no es asombroso.inicio, entonces horrible.cliente.setslave(c) final
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        --Evitar la visibilidad entre escritorios 
        awful.placement.no_offscreen(c)
    end
end)
-- Agregue una barra de título si las barras de título habilitadas están configuradas como verdaderas en las reglas.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.resize(c)
    end))

    awful.titlebar(c):setup{
        -- Documentacion (https://awesomewm.org/apidoc/popups_and_bars/awful.titlebar.html)
        { -- Izquierda
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        { -- Medio
            { -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- Derecha
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.minimizebutton(c), -- miminizar la ventana
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Habilite el enfoque descuidado, de modo que el enfoque siga al mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {
        raise = false
    })
end)
-- cuando la ventan esta seleccionada
client.connect_signal("focus", function(c)
    c.opacity = "1"
    c.border_color = tono_azul_cielo
end)
-- cuando la ventan no esta seleccionada
client.connect_signal("unfocus", function(c)
   c.opacity = "0.8"
   c.border_color = color_azul_two
end)
-- }}}
-- aplicaciones de ejecucion al inicio del entorno
awful.util.spawn("picom")--tranparencia
awful.spawn.with_shell("/usr/lib/polkit-kde-authentication-agent-1 &")--lanzador de ventana para permisos
awful.spawn.with_shell("mpd &")--cargar configuracion de reproductor
--awful.spawn.with_shell("/home/liun1x/.config/awesome/autohidewibox/autohidewibox.py")--cargar configuracion de reproductor

naughty.notify({ title = "Breake!", text = "Es hora de tomar un descanso, Humano!!", timeout = 2, bg=tono_georgias_3, border_color=tono_amarillo,})


--awful.spawn.with_shell("/usr/bin/pipewire &")--controlador de audio
--awful.spawn.with_shell("/usr/bin/pipewire-pulse &")--controlador de audio
--color del listado aplicaciones de segundo plano
beautiful.bg_systray = tono_azul_cielo

