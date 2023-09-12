/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2023 Ryo Nakano <ryonakaknock3@gmail.com>
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

    public GtkSource.View source_view { get; construct; }
    private Gtk.Button copy_clipboard_button;

    public ComboEntry (TextType text_type) {
        Object (
            text_type: text_type
        );
    }

    construct {
        var case_label = new Gtk.Label (text_type.get_case_label ());

        var case_combobox = new DropDownText () {
            halign = Gtk.Align.START,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
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

        var case_info_button_icon = new Gtk.Image.from_icon_name ("dialog-information-symbolic") {
            tooltip_text = set_info_button_tooltip (case_combobox.active_id)
        };

        copy_clipboard_button = new Gtk.Button.from_icon_name ("edit-copy") {
            margin_end = 6,
            sensitive = false,
            tooltip_text = _("Copy to Clipboard")
        };

        var toolbar_grid = new Gtk.Grid () {
            margin_start = 6,
            column_spacing = 6
        };
        toolbar_grid.attach (case_label, 0, 0);
        toolbar_grid.attach (case_combobox, 1, 0);
        toolbar_grid.attach (case_info_button_icon, 2, 0);
        toolbar_grid.attach (copy_clipboard_button, 3, 0);

        var source_buffer = new GtkSource.Buffer (null);
        source_view = new GtkSource.View.with_buffer (source_buffer) {
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            hexpand = true,
            vexpand = true
        };

        // If `this` is result_combo_entry, make source_view uneditable
        // Otherwise the app freezes
        if (text_type == TextType.RESULT) {
            source_view.editable = false;
        }

        var scrolled = new Gtk.ScrolledWindow () {
            child = source_view
        };

        attach (toolbar_grid, 0, 0);
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

        case_combobox.notify["active-id"].connect (() => {
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
            Gdk.Display.get_default ().get_clipboard ().set_text (source_buffer.text);
        });

        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
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
            source_view.remove_css_class ("text-view-light");
            source_view.add_css_class ("text-view-dark");
        } else {
            source_view.remove_css_class ("text-view-dark");
            source_view.add_css_class ("text-view-light");
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
