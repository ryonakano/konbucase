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
    private StyleManager style_manager;

    public static string COLOR_SCHEME_DEFAULT = "default";
    public static string COLOR_SCHEME_FORCE_LIGHT = "force-light";
    public static string COLOR_SCHEME_FORCE_DARK = "force-dark";

    private static Gee.HashMap<string, StyleManager.ColorScheme> style_action_transform_to_tbl;
    private static Gee.HashMap<StyleManager.ColorScheme, string> style_action_transform_from_tbl;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.konbucase",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings ("com.github.ryonakano.konbucase");

        style_action_transform_to_tbl = new Gee.HashMap<string, StyleManager.ColorScheme> ();
        style_action_transform_to_tbl[COLOR_SCHEME_DEFAULT] = StyleManager.ColorScheme.DEFAULT;
        style_action_transform_to_tbl[COLOR_SCHEME_FORCE_LIGHT] = StyleManager.ColorScheme.FORCE_LIGHT;
        style_action_transform_to_tbl[COLOR_SCHEME_FORCE_DARK] = StyleManager.ColorScheme.FORCE_DARK;

        style_action_transform_from_tbl = new Gee.HashMap<StyleManager.ColorScheme, string> ();
        style_action_transform_from_tbl[StyleManager.ColorScheme.DEFAULT] = COLOR_SCHEME_DEFAULT;
        style_action_transform_from_tbl[StyleManager.ColorScheme.FORCE_LIGHT] = COLOR_SCHEME_FORCE_LIGHT;
        style_action_transform_from_tbl[StyleManager.ColorScheme.FORCE_DARK] = COLOR_SCHEME_FORCE_DARK;
    }

    private bool style_action_transform_to_cb (Binding binding, Value from_value, ref Value to_value) {
        Variant? variant = from_value.dup_variant ();
        if (variant == null) {
            warning ("Failed to Variant.dup_variant");
            return false;
        }

        var val = variant.get_string ();
        StyleManager.ColorScheme color_scheme = style_action_transform_to_tbl[val];
        to_value.set_enum (color_scheme);

        return true;
    }

    private bool style_action_transform_from_cb (Binding binding, Value from_value, ref Value to_value) {
        var val = (StyleManager.ColorScheme) from_value;
        string color_scheme = style_action_transform_from_tbl[val];
        to_value.set_variant (new Variant.string (color_scheme));

        return true;
    }

    private static bool color_scheme_get_mapping_cb (Value value, Variant variant, void* user_data) {
        // Convert from the "style" enum defined in the gschema to StyleManager.ColorScheme
        var val = variant.get_string ();
        switch (val) {
            case Define.Style.DEFAULT:
                value.set_enum (StyleManager.ColorScheme.DEFAULT);
                break;
            case Define.Style.LIGHT:
                value.set_enum (StyleManager.ColorScheme.FORCE_LIGHT);
                break;
            case Define.Style.DARK:
                value.set_enum (StyleManager.ColorScheme.FORCE_DARK);
                break;
            default:
                warning ("color_scheme_get_mapping_cb: Invalid style: %s", val);
                return false;
        }

        return true;
    }

    private static Variant color_scheme_set_mapping_cb (Value value, VariantType expected_type, void* user_data) {
        string color_scheme;

        // Convert from StyleManager.ColorScheme to the "style" enum defined in the gschema
        var val = (StyleManager.ColorScheme) value;
        switch (val) {
            case StyleManager.ColorScheme.DEFAULT:
                color_scheme = Define.Style.DEFAULT;
                break;
            case StyleManager.ColorScheme.FORCE_LIGHT:
                color_scheme = Define.Style.LIGHT;
                break;
            case StyleManager.ColorScheme.FORCE_DARK:
                color_scheme = Define.Style.DARK;
                break;
            default:
                warning ("color_scheme_set_mapping_cb: Invalid StyleManager.ColorScheme: %d", val);
                // fallback to default
                color_scheme = Define.Style.DEFAULT;
                break;
        }

        return new Variant.string (color_scheme);
    }

    private void setup_style () {
        style_manager = StyleManager.get_default ();

        var style_action = new SimpleAction.stateful (
            "color-scheme", VariantType.STRING, new Variant.string (COLOR_SCHEME_DEFAULT)
        );
        style_action.bind_property ("state", style_manager, "color-scheme",
                                    BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
                                    style_action_transform_to_cb,
                                    style_action_transform_from_cb);
        settings.bind_with_mapping ("color-scheme", style_manager, "color-scheme", SettingsBindFlags.DEFAULT,
                                    color_scheme_get_mapping_cb,
                                    color_scheme_set_mapping_cb,
                                    null, null);
        add_action (style_action);
    }

    protected override void startup () {
        base.startup ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

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
