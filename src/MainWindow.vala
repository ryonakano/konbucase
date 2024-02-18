/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Gtk.ApplicationWindow {
    private Granite.Toast toast;

    public MainWindow (Application app) {
        Object (
            application: app,
            title: "KonbuCase"
        );
    }

    construct {
        var source_combo_entry = new Widgets.ComboEntry (
            "source",
            _("Convert from:"),
            true
        );

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            vexpand = true
        };

        var result_combo_entry = new Widgets.ComboEntry (
            "result",
            _("Convert to:"),
            // Make the text view uneditable, otherwise the app freezes
            false
        );

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.append (source_combo_entry);
        main_box.append (separator);
        main_box.append (result_combo_entry);

        toast = new Granite.Toast (_("Text copied!"));

        var overlay = new Gtk.Overlay ();
        overlay.add_overlay (main_box);
        overlay.add_overlay (toast);

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        preferences_box.append (new StyleSwitcher ());

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        var header = new Gtk.HeaderBar ();
        header.pack_end (preferences_button);
        set_titlebar (header);

        child = overlay;
        width_request = 700;
        height_request = 500;

        source_combo_entry.source_view.grab_focus ();

        source_combo_entry.text_copied.connect (show_toast);
        result_combo_entry.text_copied.connect (show_toast);
    }

    private void show_toast () {
        toast.send_notification ();
    }
}
