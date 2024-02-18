/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool IS_ON_PANTHEON {
        get {
            return Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    public static Settings settings { get; private set; }

    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };

    private MainWindow window;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.konbucase",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings ("com.github.ryonakano.konbucase");
    }

    protected override void startup () {
        base.startup ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

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

        /*
         * Binding of window maximization with "SettingsBindFlags.DEFAULT" results the window getting bigger and bigger on open.
         * So we use the prepared binding only for setting
         */
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

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
