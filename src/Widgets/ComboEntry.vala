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
                    Application.settings.get_string ("source-case-type"),
                    Application.settings.get_string ("result-case-type")
                );
            }

            return _converter;
        }
    }

    // Make sure to match with source-type enum in the gschema
    private enum CaseType {
        SPACE_SEPARATED = ChCase.Case.SPACE_SEPARATED,
        CAMEL = ChCase.Case.CAMEL,
        PASCAL = ChCase.Case.PASCAL,
        SNAKE = ChCase.Case.SNAKE,
        KEBAB = ChCase.Case.KEBAB,
        SENTENCE = ChCase.Case.SENTENCE,
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
        case_dropdown.selected = Application.settings.get_enum ("%s-case-type".printf (id));

        case_info_button_icon.tooltip_text = set_info_button_tooltip ((CaseType) case_dropdown.selected);

        source_buffer = new GtkSource.Buffer (null);
        source_view.buffer = source_buffer;

        update_buttons ();

        Application.settings.bind ("%s-text".printf (id), source_buffer, "text", SettingsBindFlags.DEFAULT);

        source_buffer.notify["text"].connect (() => {
            update_buttons ();
            convert_case ();
        });

        case_dropdown.notify["selected"].connect (() => {
            case_info_button_icon.tooltip_text = set_info_button_tooltip ((CaseType) case_dropdown.selected);

            Application.settings.set_enum ("%s-case-type".printf (id), (CaseType) case_dropdown.selected);

            if (Application.settings.get_string ("%s-text".printf (id)) != "") {
                converter.source_case_name = Application.settings.get_string ("source-case-type");
                converter.result_case_name = Application.settings.get_string ("result-case-type");
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

    private string set_info_button_tooltip (CaseType case_type) {
        switch (case_type) {
            case CaseType.SPACE_SEPARATED:
                return _("Each word is separated by a space");
            case CaseType.CAMEL:
                return _("The first character of compound words is in lowercase");
            case CaseType.PASCAL:
                return _("The first character of compound words is in uppercase");
            case CaseType.SNAKE:
                return _("Each word is separated by an underscore");
            case CaseType.KEBAB:
                return _("Each word is separated by a hyphen");
            case CaseType.SENTENCE:
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
