/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class TextPaneModel : Object {
    public Define.TextType text_type { get; construct; }
    public Define.CaseType case_type { get; set; }
    public ListStore case_listmodel { get; construct; }
    public Gtk.CClosureExpression l10n_case_expression { get; construct; }
    public GtkSource.Buffer buffer { get; construct; }
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

    public TextPaneModel (Define.TextType text_type) {
        Object (
            text_type: text_type
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum (TEXT_TYPE_DATA_TABLE[text_type].key_case_type);

        case_listmodel = new ListStore (typeof (CaseListItemModel));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.SPACE_SEPARATED,
            N_("Space separated"),
            N_("Each word is separated by a space")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.CAMEL,
            "camelCase",
            N_("The first character of compound words is in lowercase")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.PASCAL,
            "PascalCase",
            N_("The first character of compound words is in uppercase")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.SNAKE,
            "snake_case",
            N_("Each word is separated by an underscore")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.KEBAB,
            "kebab-case",
            N_("Each word is separated by a hyphen")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.SENTENCE,
            "Sentence case",
            N_("The first character of the first word in the sentence is in uppercase")
        ));

        var case_expression = new Gtk.PropertyExpression (
            typeof (CaseListItemModel), null, "name"
        );
        l10n_case_expression = new Gtk.CClosureExpression (
            typeof (string), null, { case_expression },
            (Callback) localize_str,
            null, null
        );

        buffer = new GtkSource.Buffer (null);

        style_scheme_manager = new GtkSource.StyleSchemeManager ();
        gtk_settings = Gtk.Settings.get_default ();

        // Sync with buffer text
        buffer.bind_property (
            "text",
            this, "text",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );

        // Apply theme changes to the source view
        gtk_settings.bind_property (
            "gtk-application-prefer-dark-theme",
            buffer, "style-scheme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, prefer_dark, ref style_scheme) => {
                if ((bool) prefer_dark) {
                    style_scheme = style_scheme_manager.get_scheme ("solarized-dark");
                } else {
                    style_scheme = style_scheme_manager.get_scheme ("solarized-light");
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
