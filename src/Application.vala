/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool IS_ON_PANTHEON {
        get {
            return GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    private MainWindow window;
    public static GLib.Settings settings;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.konbucase",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);
    }

    static construct {
        settings = new GLib.Settings ("com.github.ryonakano.konbucase");
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new MainWindow (this);

        int window_pos_x, window_pos_y;
        Application.settings.get ("window-position", "(ii)", out window_pos_x, out window_pos_y);

        int window_width, window_height;
        Application.settings.get ("window-size", "(ii)", out window_width, out window_height);

        if (Application.settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        if (window_pos_x != -1 || window_pos_y != -1) {
            //  window.move (window_pos_x, window_pos_y);
        }

        window.default_width = window_width;
        window.default_height = window_height;

        var quit_action = new GLib.SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});
        quit_action.activate.connect (() => {
            if (window != null) {
                window.destroy ();
            }
        });

        window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
