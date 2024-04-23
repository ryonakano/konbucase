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
            var source_case_type = (Define.CaseType) Application.settings.get_enum ("source-case-type");
            var result_case_type = (Define.CaseType) Application.settings.get_enum ("result-case-type");

            if (_converter == null) {
                _converter = new ChCase.Converter.with_case (
                    Util.Convert.to_chcase_case (source_case_type),
                    Util.Convert.to_chcase_case (result_case_type)
                );
            }

            return _converter;
        }
    }

    [GtkChild]
    private unowned Gtk.DropDown case_dropdown;
    [GtkChild]
    private unowned Gtk.Image case_info_button_icon;
    [GtkChild]
    private unowned Gtk.Button copy_clipboard_button;
    [GtkChild]
    private unowned GtkSource.View source_view;

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

        case_info_button_icon.tooltip_text = set_info_button_tooltip ((Define.CaseType) case_dropdown.selected);

        source_buffer = new GtkSource.Buffer (null);
        source_view.buffer = source_buffer;

        update_buttons ();

        Application.settings.bind ("%s-text".printf (id), source_buffer, "text", SettingsBindFlags.DEFAULT);

        source_buffer.notify["text"].connect (() => {
            update_buttons ();
            convert_case ();
        });

        case_dropdown.notify["selected"].connect (() => {
            case_info_button_icon.tooltip_text = set_info_button_tooltip ((Define.CaseType) case_dropdown.selected);

            Application.settings.set_enum ("%s-case-type".printf (id), (Define.CaseType) case_dropdown.selected);

            if (Application.settings.get_string ("%s-text".printf (id)) != "") {
                var source_case_type = (Define.CaseType) Application.settings.get_enum ("source-case-type");
                var result_case_type = (Define.CaseType) Application.settings.get_enum ("result-case-type");

                converter.source_case = Util.Convert.to_chcase_case (source_case_type);
                converter.result_case = Util.Convert.to_chcase_case (result_case_type);
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

    private string set_info_button_tooltip (Define.CaseType case_type) {
        switch (case_type) {
            case Define.CaseType.SPACE_SEPARATED:
                return _("Each word is separated by a space");
            case Define.CaseType.CAMEL:
                return _("The first character of compound words is in lowercase");
            case Define.CaseType.PASCAL:
                return _("The first character of compound words is in uppercase");
            case Define.CaseType.SNAKE:
                return _("Each word is separated by an underscore");
            case Define.CaseType.KEBAB:
                return _("Each word is separated by a hyphen");
            case Define.CaseType.SENTENCE:
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
