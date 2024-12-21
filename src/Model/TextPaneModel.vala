/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class CaseModel : Object {
    public string case_type { get; construct; }
    public string name { get; construct; }
    public string description { get; construct; }

    public CaseModel (string case_type, string name, string description) {
        Object (
            case_type: case_type,
            name: name,
            description: description
        );
    }
}

public class TextPaneModel : Object {
    public ListStore case_model { get; private set; }
    public Gtk.CClosureExpression l10n_case_expression { get; private set; }

    public Define.TextType text_type { get; construct; }
    public Define.CaseType case_type { get; set; }
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
        ChCase.Case case_type;
        string name;
        string description;
    }
    private const CaseTypeData[] CASE_TYPE_DATA_TBL = {
        {
            ChCase.Case.SPACE_SEPARATED,
            N_("Space separated"),
            N_("Each word is separated by a space")
        },
        {
            ChCase.Case.CAMEL,
            "camelCase",
            N_("The first character of compound words is in lowercase")
        },
        {
            ChCase.Case.PASCAL,
            "PascalCase",
            N_("The first character of compound words is in uppercase")
        },
        {
            ChCase.Case.SNAKE,
            "snake_case",
            N_("Each word is separated by an underscore")
        },
        {
            ChCase.Case.KEBAB,
            "kebab-case",
            N_("Each word is separated by a hyphen")
        },
        {
            ChCase.Case.SENTENCE,
            "Sentence case",
            N_("The first character of the first word in the sentence is in uppercase")
        },
    };

    public TextPaneModel (Define.TextType text_type) {
        Object (
            text_type: text_type
        );
    }

    construct {
        case_model = new ListStore (typeof (CaseModel));
        foreach (unowned var type in CASE_TYPE_DATA_TBL) {
            var item = new CaseModel (type.case_type.to_string (), type.name, type.description);
            case_model.append (item);
        }

        var case_expression = new Gtk.PropertyExpression (
            typeof (CaseModel), null, "name"
        );
        l10n_case_expression = new Gtk.CClosureExpression (typeof (string), null, { case_expression },
            (Callback) localize_str,
            null, null
        );

        case_type = (Define.CaseType) Application.settings.get_enum (TEXT_TYPE_DATA_TABLE[text_type].key_case_type);

        buffer = new GtkSource.Buffer (null);

        style_scheme_manager = new GtkSource.StyleSchemeManager ();
        gtk_settings = Gtk.Settings.get_default ();

        // Sync with buffer text
        buffer.bind_property ("text", this, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

        // Apply theme changes to the source view
        gtk_settings.bind_property (
            "gtk-application-prefer-dark-theme", buffer, "style-scheme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, from_value, ref to_value) => {
                var prefer_dark = (bool) from_value;
                if (prefer_dark) {
                    to_value.set_object (style_scheme_manager.get_scheme ("solarized-dark"));
                } else {
                    to_value.set_object (style_scheme_manager.get_scheme ("solarized-light"));
                }

                return true;
            }
        );

        Application.settings.bind (TEXT_TYPE_DATA_TABLE[text_type].key_text, this, "text", SettingsBindFlags.DEFAULT);

        notify["case-type"].connect (() => {
            Application.settings.set_enum (TEXT_TYPE_DATA_TABLE[text_type].key_case_type, case_type);
        });
    }

    private string localize_str (string str) {
        return _(str);
    }
}
