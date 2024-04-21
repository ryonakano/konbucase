/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class StyleManager : Object {
    public enum ColorScheme {
        DEFAULT,
        FORCE_LIGHT,
        FORCE_DARK,
    }

    public static string COLOR_SCHEME_DEFAULT = "default";
    public static string COLOR_SCHEME_FORCE_LIGHT = "force-light";
    public static string COLOR_SCHEME_FORCE_DARK = "force-dark";

    public static Gee.HashMap<string, ColorScheme> color_scheme_table { get; private set; }

    public ColorScheme color_scheme { get; set; }

    public static unowned StyleManager get_default () {
        if (instance == null) {
            instance = new StyleManager ();
        }

        return instance;
    }
    private static StyleManager instance = null;

    private Gtk.Settings gtk_settings;
    private Granite.Settings granite_settings;

    private StyleManager () {
    }

    static construct {
        color_scheme_table = new Gee.HashMap<string, ColorScheme> ();
        color_scheme_table[COLOR_SCHEME_DEFAULT] = ColorScheme.DEFAULT;
        color_scheme_table[COLOR_SCHEME_FORCE_LIGHT] = ColorScheme.FORCE_LIGHT;
        color_scheme_table[COLOR_SCHEME_FORCE_DARK] = ColorScheme.FORCE_DARK;
    }

    construct {
        gtk_settings = Gtk.Settings.get_default ();
        granite_settings = Granite.Settings.get_default ();

        notify["color-scheme"].connect (color_scheme_changed_cb);
        granite_settings.notify["prefers-color-scheme"].connect (color_scheme_changed_cb);
    }

    private void color_scheme_changed_cb () {
        bool is_prefer_dark;

        switch (color_scheme) {
            case ColorScheme.FORCE_LIGHT:
                is_prefer_dark = false;
                break;
            case ColorScheme.FORCE_DARK:
                is_prefer_dark = true;
                break;
            case ColorScheme.DEFAULT:
                is_prefer_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
                break;
            default:
                warning ("Invalid ColorScheme: %d", color_scheme);
                return;
        }

        gtk_settings.gtk_application_prefer_dark_theme = is_prefer_dark;
    }
}
