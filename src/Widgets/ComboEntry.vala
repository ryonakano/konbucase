/*
* Copyright 2020-2021 Ryo Nakano
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
    public TextType text_type { get; construct; }

    private static ChCase.Converter _converter;
    public static ChCase.Converter converter {
        get {
            if (_converter == null) {
                _converter = new ChCase.Converter.with_case_from_string (
                    Application.settings.get_string ("source-case-combobox"),
                    Application.settings.get_string ("result-case-combobox")
                );
            }

            return _converter;
        }
    }

    private Gtk.ToolButton copy_clipboard_button;
    private Gtk.SourceView source_view;

    public ComboEntry (TextType text_type) {
        Object (
            text_type: text_type
        );
    }

    construct {
        var case_label = new Gtk.Label (text_type.get_case_label ());

        var case_combobox = new Gtk.ComboBoxText () {
            halign = Gtk.Align.START,
            margin = 6
        };
        case_combobox.append ("space_separated", _("Space separated"));
        case_combobox.append ("camel", "camelCase");
        case_combobox.append ("pascal", "PascalCase");
        case_combobox.append ("snake", "snake_case");
        case_combobox.append ("kebab", "kebab-case");
        case_combobox.append ("sentence", "Sentence case");
        case_combobox.active_id = Application.settings.get_string (
            "%s-case-combobox".printf (text_type.get_identifier ())
        );

        var case_info_button_icon = new Gtk.Image.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.BUTTON) {
            tooltip_text = set_info_button_tooltip (case_combobox.active_id)
        };

        var case_grid = new Gtk.Grid () {
            margin_start = 6,
            column_spacing = 6
        };
        case_grid.attach (case_label, 0, 0);
        case_grid.attach (case_combobox, 1, 0);
        case_grid.attach (case_info_button_icon, 2, 0);

        var copy_clipboard_button_icon = new Gtk.Image.from_icon_name ("edit-copy", Gtk.IconSize.SMALL_TOOLBAR);
        copy_clipboard_button = new Gtk.ToolButton (copy_clipboard_button_icon, null) {
            halign = Gtk.Align.END,
            hexpand = false,
            margin_end = 6,
            sensitive = false,
            tooltip_text = _("Copy to Clipboard")
        };

        var case_combobox_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        case_combobox_box.get_style_context ().add_class ("toolbar");
        case_combobox_box.pack_start (case_grid);
        case_combobox_box.pack_end (copy_clipboard_button);

        var source_buffer = new Gtk.SourceBuffer (null);
        source_view = new Gtk.SourceView.with_buffer (source_buffer) {
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            hexpand = true,
            vexpand = true
        };

        // If `this` is result_combo_entry, make source_view uneditable
        // Otherwise the app freezes
        if (text_type == TextType.RESULT) {
            source_view.editable = false;
        }

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (source_view);

        attach (case_combobox_box, 0, 0);
        attach (scrolled, 0, 1);

        update_buttons ();

        Application.settings.bind (
            "%s-text".printf (text_type.get_identifier ()),
            source_buffer, "text", SettingsBindFlags.DEFAULT
        );

        source_buffer.notify["text"].connect (() => {
            update_buttons ();
            convert_case ();
        });

        case_combobox.changed.connect (() => {
            case_info_button_icon.tooltip_text = set_info_button_tooltip (case_combobox.active_id);

            Application.settings.set_string (
                "%s-case-combobox".printf (text_type.get_identifier ()),
                case_combobox.active_id
            );

            if (Application.settings.get_string ("%s-text".printf (text_type.get_identifier ())) != "") {
                converter.source_case_name = Application.settings.get_string ("source-case-combobox");
                converter.result_case_name = Application.settings.get_string ("result-case-combobox");
                convert_case ();
            }
        });

        copy_clipboard_button.clicked.connect (() => {
            Gtk.Clipboard.get_default (Gdk.Display.get_default ()).set_text (source_buffer.text, -1);
        });
    }

    private void update_buttons () {
        copy_clipboard_button.sensitive = Application.settings.get_string ("%s-text".printf (text_type.get_identifier ())) != "";
    }

    private void convert_case () {
        Application.settings.set_string (
            "result-text",
            converter.convert_case (Application.settings.get_string ("source-text"))
        );
    }

    public void update_color_style (bool is_prefer_dark) {
        if (is_prefer_dark) {
            source_view.get_style_context ().remove_class ("text-view-light");
            source_view.get_style_context ().add_class ("text-view-dark");
        } else {
            source_view.get_style_context ().remove_class ("text-view-dark");
            source_view.get_style_context ().add_class ("text-view-light");
        }
    }

    private string set_info_button_tooltip (string active_id) {
        switch (active_id) {
            case "space_separated":
                return _("Each word is separated by a space");
            case "camel":
                return _("The first character of compound words is in lowercase");
            case "pascal":
                return _("The first character of compound words is in uppercase");
            case "snake":
                return _("Each word is separated by an underscore");
            case "kebab":
                return _("Each word is separated by a hyphen");
            case "sentence":
                return _("The first character of the first word in the sentence is in uppercase");
            default:
                warning ("Unexpected case, no tooltip is shown.");
                return "";
        }
    }
}
