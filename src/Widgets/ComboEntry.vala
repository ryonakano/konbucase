/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/combo-entry.ui")]
public class ComboEntry : Gtk.Box {
    public signal void text_copied ();

    public string id { get; construct; }
    public string description { get; construct; }
    public bool editable { get; construct; }

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

    [GtkChild]
    private unowned Gtk.DropDown case_dropdown;
    [GtkChild]
    private unowned GtkSource.View source_view;
    [GtkChild]
    private unowned Gtk.Image case_info_button_icon;
    [GtkChild]
    private unowned Gtk.Button copy_clipboard_button;

    private GtkSource.Buffer source_buffer;

    public ComboEntry (string id, string description, bool editable) {
        Object (
            id: id,
            description: description,
            editable: editable
        );
    }

    construct {
        case_dropdown.selected = Application.settings.get_enum ("%s-case-combobox".printf (id));

        case_info_button_icon.tooltip_text = set_info_button_tooltip ((ChCase.Case) case_dropdown.selected);

        source_buffer = new GtkSource.Buffer (null);
        source_view.buffer = source_buffer;

        update_buttons ();

        Application.settings.bind ("%s-text".printf (id), source_buffer, "text", SettingsBindFlags.DEFAULT);

        source_buffer.notify["text"].connect (() => {
            update_buttons ();
            convert_case ();
        });

        case_dropdown.notify["selected"].connect (() => {
            case_info_button_icon.tooltip_text = set_info_button_tooltip ((ChCase.Case) case_dropdown.selected);

            Application.settings.set_enum ("%s-case-combobox".printf (id), (ChCase.Case) case_dropdown.selected);

            if (Application.settings.get_string ("%s-text".printf (id)) != "") {
                converter.source_case_name = Application.settings.get_string ("source-case-combobox");
                converter.result_case_name = Application.settings.get_string ("result-case-combobox");
                convert_case ();
            }
        });

        copy_clipboard_button.clicked.connect (() => {
            get_clipboard ().set_text (source_buffer.text);
            text_copied ();
        });

        var gtk_settings = Gtk.Settings.get_default ();
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
        });
        update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
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

    private string set_info_button_tooltip (ChCase.Case case_type) {
        switch (case_type) {
            case ChCase.Case.SPACE_SEPARATED:
                return _("Each word is separated by a space");
            case ChCase.Case.CAMEL:
                return _("The first character of compound words is in lowercase");
            case ChCase.Case.PASCAL:
                return _("The first character of compound words is in uppercase");
            case ChCase.Case.SNAKE:
                return _("Each word is separated by an underscore");
            case ChCase.Case.KEBAB:
                return _("Each word is separated by a hyphen");
            case ChCase.Case.SENTENCE:
                return _("The first character of the first word in the sentence is in uppercase");
            default:
                warning ("Unexpected case, no tooltip is shown.");
                return "";
        }
    }

    public unowned GtkSource.View get_source_view () {
        return source_view;
    }
}
