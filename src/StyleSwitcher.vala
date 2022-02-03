/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 * 
 * Some code inspired from elementary/switchboard-plug-pantheon-shell, src/Views/Appearance.vala
 */

public class StyleSwitcher : Gtk.Box {
    private Gtk.Settings gtk_settings;
    private Granite.Settings granite_settings;

    private Gtk.ToggleButton light_style_button;
    private Gtk.ToggleButton dark_style_button;
    private Gtk.ToggleButton system_style_button;

    public StyleSwitcher () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 6
        );
    }

    construct {
        gtk_settings = Gtk.Settings.get_default ();

        var style_label = new Gtk.Label (_("Style:")) {
            halign = Gtk.Align.START
        };

        var light_style_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        light_style_box.append (new Gtk.Image.from_icon_name ("display-brightness-symbolic"));
        light_style_box.append (new Gtk.Label (_("Light")));
        light_style_button = new Gtk.ToggleButton () {
            child = light_style_box,
            can_focus = false
        };

        var dark_style_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        dark_style_box.append (new Gtk.Image.from_icon_name ("weather-clear-night-symbolic"));
        dark_style_box.append (new Gtk.Label (_("Dark")));
        dark_style_button = new Gtk.ToggleButton () {
            child = dark_style_box,
            can_focus = false,
            group = light_style_button
        };

        var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        buttons_box.append (light_style_button);
        buttons_box.append (dark_style_button);

        if (Application.IS_ON_PANTHEON) {
            granite_settings = Granite.Settings.get_default ();

            var system_style_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
            system_style_box.append (new Gtk.Image.from_icon_name ("emblem-system-symbolic"));
            system_style_box.append (new Gtk.Label (_("System")));
            system_style_button = new Gtk.ToggleButton () {
                child = system_style_box,
                can_focus = false,
                group = light_style_button
            };

            buttons_box.append (system_style_button);

            granite_settings.notify["prefers-color-scheme"].connect (() => {
                construct_app_style ();
            });
 
            system_style_button.toggled.connect (() => {
                set_app_style (
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK,
                    true
                );
            });
        }

        light_style_button.toggled.connect (() => {
            set_app_style (false, false);
        });

        dark_style_button.toggled.connect (() => {
            set_app_style (true, false);
        });

        construct_app_style ();

        append (style_label);
        append (buttons_box);
    }

    private void set_app_style (bool is_prefer_dark, bool is_follow_system_style) {
        gtk_settings.gtk_application_prefer_dark_theme = is_prefer_dark;
        Application.settings.set_boolean ("is-prefer-dark", is_prefer_dark);
        Application.settings.set_boolean ("is-follow-system-style", is_follow_system_style);
    }

    private void construct_app_style () {
        if (Application.settings.get_boolean ("is-follow-system-style")) {
            set_app_style (granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK, true);
            system_style_button.active = true;
        } else {
            bool is_prefer_dark = Application.settings.get_boolean ("is-prefer-dark");
            set_app_style (is_prefer_dark, false);
            if (is_prefer_dark) {
                dark_style_button.active = true;
            } else {
                light_style_button.active = true;
            }
        }
    }
}
