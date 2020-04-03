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
    private Services.Buffer target_source_buffer;
    private Services.Buffer result_source_buffer;

    private Gtk.Grid buttons_grid;
    private Gtk.ToolButton copy_clipboard_button;
    private Gtk.ToolButton undo_button;
    private Gtk.ToolButton redo_button;

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

        var target_case_combo = new Gtk.ComboBoxText ();
        target_case_combo.halign = Gtk.Align.START;
        target_case_combo.margin = 6;
        target_case_combo.append ("space_separated", _("Space separated"));
        target_case_combo.append ("camel", "camelCase");
        target_case_combo.append ("pascal", "PascalCase");
        target_case_combo.append ("snake", "snake_case");
        target_case_combo.append ("kebab", "kebab-case");

        var target_case_combo_grid = new Gtk.Grid ();
        target_case_combo_grid.get_style_context ().add_class ("toolbar");
        target_case_combo_grid.margin = 0;
        target_case_combo_grid.add (target_case_combo);

        target_source_buffer = new Services.Buffer ();
        var target_source_view = new Gtk.SourceView.with_buffer (target_source_buffer);
        target_source_view.get_style_context ().add_class ("text-view");
        target_source_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        target_source_view.hexpand = true;
        target_source_view.vexpand = true;

        var target_scrolled = new Gtk.ScrolledWindow (null, null);
        target_scrolled.add (target_source_view);

        var result_case_combo = new Gtk.ComboBoxText ();
        result_case_combo.halign = Gtk.Align.START;
        result_case_combo.margin = 6;
        result_case_combo.append ("space_separated", _("Space separated"));
        result_case_combo.append ("camel", "camelCase");
        result_case_combo.append ("pascal", "PascalCase");
        result_case_combo.append ("snake", "snake_case");
        result_case_combo.append ("kebab", "kebab-case");

        var result_case_combo_grid = new Gtk.Grid ();
        result_case_combo_grid.get_style_context ().add_class ("toolbar");
        result_case_combo_grid.margin = 0;
        result_case_combo_grid.add (result_case_combo);

        result_source_buffer = new Services.Buffer ();
        var result_source_view = new Gtk.SourceView.with_buffer (result_source_buffer);
        result_source_view.get_style_context ().add_class ("text-view");
        result_source_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        result_source_view.hexpand = true;
        result_source_view.vexpand = true;

        var result_scrolled = new Gtk.ScrolledWindow (null, null);
        result_scrolled.add (result_source_view);

        var grid = new Gtk.Grid ();
        grid.margin = 0;
        grid.attach (target_case_combo_grid, 0, 0);
        grid.attach (target_scrolled, 0, 1);
        grid.attach (result_case_combo_grid, 0, 2);
        grid.attach (result_scrolled, 0, 3);

        var copy_clipboard_button_icon = new Gtk.Image.from_icon_name ("edit-copy", Gtk.IconSize.SMALL_TOOLBAR);
        copy_clipboard_button = new Gtk.ToolButton (copy_clipboard_button_icon, null);
        copy_clipboard_button.sensitive = false;
        copy_clipboard_button.tooltip_text = _("Copy to Clipboard");

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = _("KonbuCase");
        header.pack_start (copy_clipboard_button);

        set_titlebar (header);
        add (grid);

        update_buttons ();

        target_source_buffer.notify["text"].connect (() => {
            update_buttons ();
        });

        copy_clipboard_button.clicked.connect (() => {
            Gtk.Clipboard.get_default (Gdk.Display.get_default ()).set_text (target_source_buffer.text, -1);
        });

        delete_event.connect (e => {
            return before_destroy ();
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

    private void update_buttons () {
        bool has_text = target_source_buffer.text != "";

        copy_clipboard_button.sensitive = has_text;
    }
}
