/*
* Copyright 2020 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class Application : Gtk.Application {
    private MainWindow window;
    public static GLib.Settings settings;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.konbucase",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new GLib.Settings ("com.github.ryonakano.konbucase");
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new MainWindow (this);

        int window_pos_x, window_pos_y;
        Application.settings.get ("window-position", "(ii)", out window_pos_x, out window_pos_y);

        int window_width, window_height;
        Application.settings.get ("window-size", "(ii)", out window_width, out window_height);

        if (Application.settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        if (window_pos_x != -1 || window_pos_y != -1) {
            window.move (window_pos_x, window_pos_y);
        } else {
            window.window_position = Gtk.WindowPosition.CENTER;
        }

        window.resize (window_width, window_height);
        window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
