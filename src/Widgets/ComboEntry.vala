/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Widgets.ComboEntry : Gtk.Grid {
    public string id { get; construct; }
    public string description { get; construct; }
    public bool editable { get; construct; }

    public GtkSource.View source_view { get; construct; }

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

    private GtkSource.Buffer source_buffer;
    private Gtk.Button copy_clipboard_button;

    public ComboEntry (string id, string description, bool editable) {
        Object (
            id: id,
            description: description,
            editable: editable
        );
    }

    construct {
        var case_label = new Gtk.Label (description);

        var case_combobox = new Ryokucha.DropDownText () {
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
            "%s-case-combobox".printf (id)
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

        source_buffer = new GtkSource.Buffer (null);
        source_view = new GtkSource.View.with_buffer (source_buffer) {
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            hexpand = true,
            vexpand = true,
            editable = editable
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = source_view
        };

        attach (toolbar_grid, 0, 0);
        attach (scrolled, 0, 1);

        update_buttons ();

        Application.settings.bind ("%s-text".printf (id), source_buffer, "text", SettingsBindFlags.DEFAULT);

        source_buffer.notify["text"].connect (() => {
            update_buttons ();
            convert_case ();
        });

        case_combobox.changed.connect (() => {
            case_info_button_icon.tooltip_text = set_info_button_tooltip (case_combobox.active_id);

            Application.settings.set_string ("%s-case-combobox".printf (id), case_combobox.active_id);

            if (Application.settings.get_string ("%s-text".printf (id)) != "") {
                converter.source_case_name = Application.settings.get_string ("source-case-combobox");
                converter.result_case_name = Application.settings.get_string ("result-case-combobox");
                convert_case ();
            }
        });

        copy_clipboard_button.clicked.connect (() => {
            get_clipboard ().set_text (source_buffer.text);
        });

        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
        });
    }

    private void update_buttons () {
        copy_clipboard_button.sensitive = Application.settings.get_string ("%s-text".printf (id)) != "";
    }

    private void convert_case () {
        Application.settings.set_string (
            "result-text",
            converter.convert_case (Application.settings.get_string ("source-text"))
        );
    }

    public void update_color_style (bool is_prefer_dark) {
        if (is_prefer_dark) {
            source_buffer.style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-dark");
        } else {
            source_buffer.style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-light");
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
