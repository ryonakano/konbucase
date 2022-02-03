/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Gtk.ApplicationWindow {
    private uint configure_id;

    public MainWindow (Application app) {
        Object (
            application: app,
            title: "KonbuCase"
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/konbucase/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var source_combo_entry = new Widgets.ComboEntry (TextType.SOURCE);

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            vexpand = true
        };

        var result_combo_entry = new Widgets.ComboEntry (TextType.RESULT);

        var grid = new Gtk.Grid ();
        grid.attach (source_combo_entry, 0, 0);
        grid.attach (separator, 1, 0);
        grid.attach (result_combo_entry, 2, 0);

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        //  preferences_box.add (new StyleSwitcher ());

        var preferences_button = new Gtk.ToolButton (
            new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR), null
        ) {
            tooltip_text = _("Preferences")
        };

        var preferences_popover = new Gtk.Popover ();
        preferences_popover.child = preferences_button;
        preferences_popover.default_widget = preferences_box;

        preferences_button.clicked.connect (() => {
            preferences_popover.show_all ();
        });

        var header = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("KonbuCase")
        };
        header.pack_end (preferences_button);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (header);
        main_box.append (grid);

        child = main_box;

        source_combo_entry.source_view.grab_focus ();

        notify["default-width"].connect (() => {
            save_window_size ();
        });

        notify["default-height"].connect (() => {
            save_window_size ();
        });

        notify["fullscreened"].connect (() => {
            Application.settings.set_boolean ("window-maximized", fullscreened);
        });
    }

    private void save_window_size () {
        Application.settings.set ("window-size", "(ii)", default_width, default_height);
    }
}
