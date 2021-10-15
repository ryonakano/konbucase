/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Hdy.Window {
    private uint configure_id;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        Hdy.init ();

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/konbucase/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var source_combo_entry = new Widgets.ComboEntry (TextType.SOURCE);

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            vexpand = true
        };

        var result_combo_entry = new Widgets.ComboEntry (TextType.RESULT);

        var grid = new Gtk.Grid () {
            margin = 0
        };
        grid.attach (source_combo_entry, 0, 0);
        grid.attach (separator, 1, 0);
        grid.attach (result_combo_entry, 2, 0);

        var header = new Hdy.HeaderBar () {
            has_subtitle = false,
            show_close_button = true,
            title = _("KonbuCase")
        };

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.add (header);
        main_box.add (grid);

        add (main_box);

#if FOR_PANTHEON
        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        ) {
            primary_icon_tooltip_text = _("Light background"),
            secondary_icon_tooltip_text = _("Dark background"),
            valign = Gtk.Align.CENTER
        };

        //TRANSLATORS: Whether to follow system's dark style settings
        var follow_system_label = new Gtk.Label (_("Follow system style:")) {
            halign = Gtk.Align.END
        };

        var follow_system_switch = new Gtk.Switch () {
            halign = Gtk.Align.START
        };

        var preferences_grid = new Gtk.Grid () {
            margin = 12,
            column_spacing = 6,
            row_spacing = 6
        };
        preferences_grid.attach (follow_system_label, 0, 0);
        preferences_grid.attach (follow_system_switch, 1, 0);

        var preferences_button_icon = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        var preferences_button = new Gtk.ToolButton (preferences_button_icon, null) {
            tooltip_text = _("Preferences")
        };

        var preferences_popover = new Gtk.Popover (preferences_button);
        preferences_popover.add (preferences_grid);

        preferences_button.clicked.connect (() => {
            preferences_popover.show_all ();
        });

        header.pack_end (preferences_button);
        header.pack_end (mode_switch);

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            if (Application.settings.get_boolean ("is-follow-system-style")) {
                gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            }
        });

        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            source_combo_entry.update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
            result_combo_entry.update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
        });

        follow_system_switch.notify["active"].connect (() => {
            if (follow_system_switch.active) {
                gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            } else {
                gtk_settings.gtk_application_prefer_dark_theme = Application.settings.get_boolean ("is-prefer-dark");
            }
        });

        Application.settings.bind ("is-prefer-dark", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);
        Application.settings.bind ("is-prefer-dark", gtk_settings, "gtk-application-prefer-dark-theme", GLib.SettingsBindFlags.DEFAULT);
        Application.settings.bind ("is-follow-system-style", follow_system_switch, "active", GLib.SettingsBindFlags.DEFAULT);
        Application.settings.bind ("is-follow-system-style", mode_switch, "sensitive", GLib.SettingsBindFlags.INVERT_BOOLEAN);
#else
        source_combo_entry.update_color_style (false);
        result_combo_entry.update_color_style (false);
#endif
    }

    protected override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = GLib.Timeout.add (100, () => {
            configure_id = 0;
            int width, height, x, y;
            get_size (out width, out height);
            get_position (out x, out y);

            Application.settings.set ("window-position", "(ii)", x, y);
            Application.settings.set ("window-size", "(ii)", width, height);
            Application.settings.set_boolean ("window-maximized", this.is_maximized);

            return Gdk.EVENT_PROPAGATE;
        });

        return base.configure_event (event);
    }
}
