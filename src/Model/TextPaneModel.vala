/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class TextPaneModel : Object {
    public Define.TextType text_type { get; construct; }
    public Define.CaseType case_type { get; set; }
    public string case_description { get; set; }
    public GtkSource.Buffer buffer { get; private set; }
    public string text { get; set; }

    private GtkSource.StyleSchemeManager style_scheme_manager;
    private Gtk.Settings gtk_settings;

    private struct TextTypeData {
        /** GSettings key name that stores last case type. */
        string key_case_type;
        /** GSettings key name that stores last text. */
        string key_text;
    }
    private const TextTypeData[] TEXT_TYPE_DATA_TABLE = {
        { "source-case-type", "source-text" }, // Define.TextType.SOURCE
        { "result-case-type", "result-text" }, // Define.TextType.RESULT
    };

    private struct CaseTypeData {
        string description;
    }
    private const CaseTypeData[] CASE_TYPE_DATA_TBL = {
        { N_("Each word is separated by a space") }, // Define.CaseType.SPACE_SEPARATED
        { N_("The first character of compound words is in lowercase") }, // Define.CaseType.CAMEL
        { N_("The first character of compound words is in uppercase") }, // Define.CaseType.PASCAL
        { N_("Each word is separated by an underscore") }, // Define.CaseType.SNAKE
        { N_("Each word is separated by a hyphen") }, // Define.CaseType.KEBAB
        { N_("The first character of the first word in the sentence is in uppercase") }, // Define.CaseType.SENTENCE
    };

    public TextPaneModel (Define.TextType text_type) {
        Object (
            text_type: text_type
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum (TEXT_TYPE_DATA_TABLE[text_type].key_case_type);

        buffer = new GtkSource.Buffer (null);

        style_scheme_manager = new GtkSource.StyleSchemeManager ();
        gtk_settings = Gtk.Settings.get_default ();

        // Sync with buffer text
        buffer.bind_property ("text", this, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

        // Apply theme changes to the source view
        gtk_settings.bind_property ("gtk-application-prefer-dark-theme", buffer, "style-scheme",
                                    BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                                    (binding, from_value, ref to_value) => {
                                        var prefer_dark = (bool) from_value;
                                        if (prefer_dark) {
                                            to_value.set_object (style_scheme_manager.get_scheme ("solarized-dark"));
                                        } else {
                                            to_value.set_object (style_scheme_manager.get_scheme ("solarized-light"));
                                        }

                                        return true;
                                    });

        Application.settings.bind (TEXT_TYPE_DATA_TABLE[text_type].key_text, this, "text", SettingsBindFlags.DEFAULT);

        bind_property ("case-type", this, "case-description",
                       BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                       (binding, from_value, ref to_value) => {
                           var case_type = (Define.CaseType) from_value;
                           to_value.set_string (_(CASE_TYPE_DATA_TBL[case_type].description));
                           return true;
                       });

        notify["case-type"].connect (() => {
            Application.settings.set_enum (TEXT_TYPE_DATA_TABLE[text_type].key_case_type, case_type);
        });
    }
}
