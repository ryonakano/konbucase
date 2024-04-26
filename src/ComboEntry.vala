/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/combo-entry.ui")]
public class ComboEntry : Gtk.Box {
    /** Notify change of currently selected item in {@link case_dropdown}. */
    public signal void dropdown_changed ();
    /** Notify change of text in {@link source_view}. */
    public signal void text_changed ();
    /** Notify that text in {@link source_view} is copied. */
    public signal void text_copied ();

    public Define.TextType text_type { get; construct; }
    public string description { get; construct; }
    public bool editable { get; construct; }

    public Define.CaseType case_type { get; set; }
    public GtkSource.Buffer buffer { get; private set; }
    public string text { get; set; }

    private GtkSource.StyleSchemeManager style_scheme_manager;
    private Gtk.Settings gtk_settings;

    private struct ComboEntryCtx {
        /** GSettings key name that stores last case type. */
        string key_case_type;
        /** GSettings key name that stores last text. */
        string key_text;
    }
    private const ComboEntryCtx[] CTX_TABLE = {
        { "source-case-type", "source-text" }, // Define.TextType.SOURCE
        { "result-case-type", "result-text" }, // Define.TextType.RESULT
    };

    private struct CaseInfo {
        /** Tooltip text for {@link case_info_button_icon}. */
        string info_text;
    }
    private const CaseInfo[] CASE_INFO_TBL = {
        { N_("Each word is separated by a space") }, // Define.CaseType.SPACE_SEPARATED
        { N_("The first character of compound words is in lowercase") }, // Define.CaseType.CAMEL
        { N_("The first character of compound words is in uppercase") }, // Define.CaseType.PASCAL
        { N_("Each word is separated by an underscore") }, // Define.CaseType.SNAKE
        { N_("Each word is separated by a hyphen") }, // Define.CaseType.KEBAB
        { N_("The first character of the first word in the sentence is in uppercase") }, // Define.CaseType.SENTENCE
    };

    [GtkChild]
    private unowned Gtk.DropDown case_dropdown;
    [GtkChild]
    private unowned Gtk.Image case_info_button_icon;
    [GtkChild]
    private unowned Gtk.Button copy_clipboard_button;
    [GtkChild]
    private unowned GtkSource.View source_view;

    public ComboEntry (Define.TextType text_type, string description, bool editable) {
        Object (
            text_type: text_type,
            description: description,
            editable: editable
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum (CTX_TABLE[text_type].key_case_type);
        case_dropdown.selected = case_type;

        buffer = new GtkSource.Buffer (null);
        source_view.buffer = buffer;

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

        Application.settings.bind (CTX_TABLE[text_type].key_text, this, "text", SettingsBindFlags.DEFAULT);

        notify["case-type"].connect (() => {
            Application.settings.set_enum (CTX_TABLE[text_type].key_case_type, case_type);
        });

        case_dropdown.notify["selected"].connect (() => {
            case_type = (Define.CaseType) case_dropdown.selected;

            dropdown_changed ();
        });

        copy_clipboard_button.clicked.connect (() => {
            get_clipboard ().set_text (text);
            text_copied ();
        });

        // Make copy button insensitive when text is blank
        bind_property ("text", copy_clipboard_button, "sensitive",
                             BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                             (binding, from_value, ref to_value) => {
                                 var text = (string) from_value;
                                 to_value.set_boolean (text != "");
                                 return true;
                             });

        // Set tooltip text of info button depending on selected case type
        bind_property ("case-type", case_info_button_icon, "tooltip-text",
                             BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                             (binding, from_value, ref to_value) => {
                                 var case_type = (Define.CaseType) from_value;
                                 to_value.set_string (_(CASE_INFO_TBL[case_type].info_text));
                                 return true;
                             });

        notify["text"].connect (() => {
            text_changed ();
        });
    }

    // UI elements defined in .ui files can't be a property, so defines a getter method instead
    public unowned GtkSource.View get_source_view () {
        return source_view;
    }
}
