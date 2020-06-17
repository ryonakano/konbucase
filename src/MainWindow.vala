/*
* Copyright 2020 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class MainWindow : Gtk.ApplicationWindow {
    private uint configure_id;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/konbucase/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var target_combo_entry = new Widgets.ComboEntry (TextType.TARGET);
        var result_combo_entry = new Widgets.ComboEntry (TextType.RESULT);

        var grid = new Gtk.Grid ();
        grid.margin = 0;
        grid.attach (target_combo_entry, 0, 0);
        grid.attach (result_combo_entry, 0, 1);

        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        );
        mode_switch.primary_icon_tooltip_text = _("Light background");
        mode_switch.secondary_icon_tooltip_text = _("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;

        //TRANSLATORS: Whether to follow system's dark style settings
        var follow_system_label = new Gtk.Label (_("Follow system style:"));
        follow_system_label.halign = Gtk.Align.END;

        var follow_system_switch = new Gtk.Switch ();
        follow_system_switch.halign = Gtk.Align.START;

        var preferences_grid = new Gtk.Grid ();
        preferences_grid.margin = 12;
        preferences_grid.column_spacing = 6;
        preferences_grid.row_spacing = 6;
        preferences_grid.attach (follow_system_label, 0, 0);
        preferences_grid.attach (follow_system_switch, 1, 0);

        var preferences_button_icon = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        var preferences_button = new Gtk.ToolButton (preferences_button_icon, null);
        preferences_button.tooltip_text = _("Preferences");

        var preferences_popover = new Gtk.Popover (preferences_button);
        preferences_popover.add (preferences_grid);

        preferences_button.clicked.connect (() => {
            preferences_popover.show_all ();
        });

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = _("KonbuCase");
        header.pack_end (preferences_button);
        header.pack_end (mode_switch);

        set_titlebar (header);
        add (grid);

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            if (Application.settings.get_boolean ("is-follow-system-style")) {
                gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            }
        });

        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            target_combo_entry.update_color_style (gtk_settings.gtk_application_prefer_dark_theme);
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
