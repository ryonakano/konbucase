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

public class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        var window_pos_x = Application.settings.get_int ("pos-x");
        var window_pos_y = Application.settings.get_int ("pos-y");
        var window_width = Application.settings.get_int ("window-width");
        var window_height = Application.settings.get_int ("window-height");
        var window_max = Application.settings.get_boolean ("window-maximized");

        if (window_max == true) {
            maximize ();
        }
        if (window_pos_x != -1 || window_pos_y != -1) {
            move (window_pos_x, window_pos_y);
        } else {
            window_position = Gtk.WindowPosition.CENTER;
        }

        resize (window_width, window_height);

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/konbucase/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var target_combo_entry = new Widgets.ComboEntry (TextType.TARGET);
        var result_combo_entry = new Widgets.ComboEntry (TextType.RESULT);

        var grid = new Gtk.Grid ();
        grid.margin = 0;
        grid.attach (target_combo_entry, 0, 0);
        grid.attach (result_combo_entry, 0, 1);

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = _("KonbuCase");

        set_titlebar (header);
        add (grid);

        delete_event.connect (e => {
            return before_destroy ();
        });

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        target_combo_entry.update_color_style (granite_settings.prefers_color_scheme);
        result_combo_entry.update_color_style (granite_settings.prefers_color_scheme);

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            target_combo_entry.update_color_style (granite_settings.prefers_color_scheme);
            result_combo_entry.update_color_style (granite_settings.prefers_color_scheme);
        });
    }

    private bool before_destroy () {
        int width, height, x, y;
        var max = is_maximized;

        get_size (out width, out height);
        get_position (out x, out y);

        Application.settings.set_int ("pos-x", x);
        Application.settings.set_int ("pos-y", y);
        Application.settings.set_int ("window-width", width);
        Application.settings.set_int ("window-height", height);
        Application.settings.set_boolean ("window-maximized", max);

        return false;
    }
}
