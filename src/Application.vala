/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Adw.Application {
    public static Settings settings { get; private set; }

    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
        { "about", on_about_activate },
    };
    private MainWindow window;

    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.DEFAULT_FLAGS,
            resource_base_path: Config.RESOURCE_PREFIX
        );
    }

    static construct {
        settings = new Settings (Config.APP_ID);
    }

    private void setup_style () {
        var style_action = new SimpleAction.stateful (
            "color-scheme", VariantType.STRING, new Variant.string (Define.ColorScheme.DEFAULT)
        );
        style_action.bind_property (
            "state",
            style_manager, "color-scheme",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
            (binding, state_scheme, ref adw_scheme) => {
                Variant? state_scheme_dup = state_scheme.dup_variant ();
                if (state_scheme_dup == null) {
                    warning ("Failed to Variant.dup_variant");
                    return false;
                }

                adw_scheme = Util.to_adw_scheme ((string) state_scheme_dup);
                return true;
            },
            (binding, adw_scheme, ref state_scheme) => {
                string str_scheme = Util.to_str_scheme ((Adw.ColorScheme) adw_scheme);
                state_scheme = new Variant.string (str_scheme);
                return true;
            }
        );
        settings.bind_with_mapping (
            "color-scheme",
            style_manager, "color-scheme", SettingsBindFlags.DEFAULT,
            (adw_scheme, gschema_scheme, user_data) => {
                adw_scheme = Util.to_adw_scheme ((string) gschema_scheme);
                return true;
            },
            (adw_scheme, expected_type, user_data) => {
                string str_scheme = Util.to_str_scheme ((Adw.ColorScheme) adw_scheme);
                Variant gschema_scheme = new Variant.string (str_scheme);
                return gschema_scheme;
            },
            null, null
        );
        add_action (style_action);
    }

    protected override void startup () {
#if USE_GRANITE
        // Use both compile-time and runtime conditions to:
        //
        //  * make Granite optional dependency
        //  * make sure to respect currently running DE
        if (Util.is_on_pantheon ()) {
            // Apply elementary stylesheet instead of default Adwaita stylesheet
            Granite.init ();
        }
#endif

        base.startup ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        setup_style ();

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q" });
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new MainWindow (this);
        // The window seems to need showing before restoring its size in Gtk4
        window.present ();

        settings.bind ("window-height", window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", window, "default-width", SettingsBindFlags.DEFAULT);

        // Binding of window maximization with "SettingsBindFlags.DEFAULT" results the window getting bigger and bigger on open.
        // So we use the prepared binding only for setting.
        if (Application.settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        settings.bind ("window-maximized", window, "maximized", SettingsBindFlags.SET);
    }

    private void on_quit_activate () {
        if (window != null) {
            window.destroy ();
        }
    }

    private void on_about_activate () {
        // List of maintainers
        const string[] DEVELOPERS = {
            "Ryo Nakano https://github.com/ryonakano",
        };
        // List of icon authors
        const string[] ARTISTS = {
            "Ryo Nakano https://github.com/ryonakano",
            "Nararyans R.I. https://github.com/Fatih20",
            "Leo https://github.com/lenemter",
        };

        var about_dialog = new Adw.AboutDialog.from_appdata (
            "%s/%s.metainfo.xml".printf (Config.RESOURCE_PREFIX, Config.APP_ID),
            null
        ) {
            version = Config.APP_VERSION,
            copyright = "© 2020-2025 Ryo Nakano",
            developers = DEVELOPERS,
            artists = ARTISTS,
            ///TRANSLATORS: A newline-separated list of translators. Don't translate literally.
            ///You can optionally add your name if you want, plus you may add your email address or website.
            ///e.g.:
            ///John Doe
            ///John Doe <john-doe@example.com>
            ///John Doe https://example.com
            translator_credits = _("translator-credits")
        };
        about_dialog.present (get_active_window ());
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
