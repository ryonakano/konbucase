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

public class Widgets.ComboEntry : Gtk.Grid {
    public string case_label_text { get; construct; }
    public Gtk.ComboBoxText case_combobox { get; set; }
    public Gtk.SourceBuffer source_buffer { get; private set; }

    private Gtk.ToolButton copy_clipboard_button;

    public ComboEntry (string case_label_text) {
        Object (
            case_label_text: case_label_text,
            margin: 0
        );
    }

    construct {
        var case_label = new Gtk.Label (case_label_text);

        case_combobox = new Gtk.ComboBoxText ();
        case_combobox.halign = Gtk.Align.START;
        case_combobox.margin = 6;
        case_combobox.append ("space_separated", _("Space separated"));
        case_combobox.append ("camel", "camelCase");
        case_combobox.append ("pascal", "PascalCase");
        case_combobox.append ("snake", "snake_case");
        case_combobox.append ("kebab", "kebab-case");

        var case_grid = new Gtk.Grid ();
        case_grid.margin_start = 6;
        case_grid.attach (case_label, 0, 0);
        case_grid.attach (case_combobox, 1, 0);

        var copy_clipboard_button_icon = new Gtk.Image.from_icon_name ("edit-copy", Gtk.IconSize.SMALL_TOOLBAR);
        copy_clipboard_button = new Gtk.ToolButton (copy_clipboard_button_icon, null);
        copy_clipboard_button.halign = Gtk.Align.END;
        copy_clipboard_button.hexpand = false;
        copy_clipboard_button.margin_end = 6;
        copy_clipboard_button.sensitive = false;
        copy_clipboard_button.tooltip_text = _("Copy to Clipboard");

        var case_combobox_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        case_combobox_box.get_style_context ().add_class ("toolbar");
        case_combobox_box.margin = 0;
        case_combobox_box.pack_start (case_grid);
        case_combobox_box.pack_end (copy_clipboard_button);

        source_buffer = new Gtk.SourceBuffer (null);
        var source_view = new Gtk.SourceView.with_buffer (source_buffer);
        source_view.get_style_context ().add_class ("text-view");
        source_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        source_view.hexpand = true;
        source_view.vexpand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (source_view);

        attach (case_combobox_box, 0, 0);
        attach (scrolled, 0, 1);

        update_buttons ();

        copy_clipboard_button.clicked.connect (() => {
            Gtk.Clipboard.get_default (Gdk.Display.get_default ()).set_text (source_buffer.text, -1);
        });
    }

    public void update_buttons () {
        copy_clipboard_button.sensitive = source_buffer.text != "";
    }
}
