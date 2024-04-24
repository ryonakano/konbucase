/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class ComboEntryModel : Object {
    public Define.TextType text_type { get; construct; }

    public Define.CaseType case_type { get; set; }
    public GtkSource.Buffer buffer { get; private set; }
    public string text { get; set; }

    private GtkSource.StyleSchemeManager style_scheme_manager;
    private Gtk.Settings gtk_settings;

    private struct ComboEntryCtx {
        string key_case_type;
        string key_text;
    }
    private const ComboEntryCtx[] CTX_TABLE = {
        { "source-case-type", "source-text" },
        { "result-case-type", "result-text" },
    };

    public ComboEntryModel (Define.TextType text_type) {
        Object (
            text_type: text_type
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum (CTX_TABLE[text_type].key_case_type);

        buffer = new GtkSource.Buffer (null);
        style_scheme_manager = new GtkSource.StyleSchemeManager ();
        gtk_settings = Gtk.Settings.get_default ();

        Application.settings.bind (CTX_TABLE[text_type].key_text, buffer, "text", SettingsBindFlags.DEFAULT);
        buffer.bind_property ("text", this, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

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

        notify["case-type"].connect (() => {
            Application.settings.set_enum (CTX_TABLE[text_type].key_case_type, case_type);
        });
    }
}
