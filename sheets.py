import gi
import os
import subprocess
gi.require_version("Gtk", "4.0")  
from gi.repository import Gtk, Gdk, Gio
COMMANDS_FILE = os.path.expanduser("~/.saved_commands")
if not os.path.exists(COMMANDS_FILE):
    with open(COMMANDS_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join([f"Команда {i}" for i in range(1, 51)]) + "\n")  
class CommandWindow(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        display = Gdk.Display.get_default()
        monitor = display.get_primary_monitor()
        screen_width = monitor.get_geometry().width
        screen_height = monitor.get_geometry().height
        window_width = int(screen_width * 0.33)  
        window_height = int(screen_height * 0.8)  
        self.set_default_size(window_width, window_height)
        self.set_decorated(False)  
        self.set_modal(True)  
        self.liststore = Gtk.ListStore(str)
        self.load_commands()
        treeview = Gtk.TreeView(model=self.liststore)
        treeview.set_vexpand(True)  
        treeview.set_hexpand(True)  
        treeview.set_headers_visible(False)  
        renderer = Gtk.CellRendererText()
        column = Gtk.TreeViewColumn("Команды", renderer, text=0)
        treeview.append_column(column)
        treeview.connect("row-activated", self.on_command_selected)
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scrolled_window.set_child(treeview)
        self.set_child(scrolled_window)
        self.connect("close-request", self.on_focus_out)
        self.add_controller(self.create_esc_controller())
    def create_esc_controller(self):
        """Добавляет обработчик выхода по Esc"""
        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        return key_controller
    def on_key_pressed(self, controller, keyval, keycode, state):
        """Выход при нажатии Esc"""
        if keyval == Gdk.KEY_Escape:
            self.close()
            return True
        return False
    def load_commands(self):
        """Загружает команды из файла"""
        with open(COMMANDS_FILE, "r", encoding="utf-8") as f:
            for line in f:
                self.liststore.append([line.strip()])
    def on_command_selected(self, widget, path, column):
        """Копирует команду в буфер при выборе"""
        command = self.liststore[path][0]
        subprocess.run(["xclip", "-selection", "clipboard"], input=command.encode())
        subprocess.run(["notify-send", "Команда скопирована", command])
        self.close()
    def on_focus_out(self, widget):
        """Закрывает окно при потере фокуса"""
        self.close()
class CommandApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.example.commands",
                         flags=Gio.ApplicationFlags.FLAGS_NONE)
    def do_activate(self):
        """Создаёт и показывает окно"""
        win = CommandWindow(self)
        win.present()
app = CommandApp()
app.run()
