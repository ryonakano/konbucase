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

        var style_submenu = new Menu ();
        style_submenu.append (_("Light"), "app.color-scheme(%d)".printf (StyleManager.ColorScheme.FORCE_LIGHT));
        style_submenu.append (_("Dark"), "app.color-scheme(%d)".printf (StyleManager.ColorScheme.FORCE_DARK));
        style_submenu.append (_("System"), "app.color-scheme(%d)".printf (StyleManager.ColorScheme.DEFAULT));

        var menu = new Menu ();
        menu.append_submenu (_("Style"), style_submenu);

        var menu_button = new Gtk.MenuButton () {
            tooltip_text = _("Main Menu"),
            icon_name = "open-menu-symbolic",
            menu_model = menu,
            primary = true
        };

        var header = new Gtk.HeaderBar ();
        header.pack_end (menu_button);
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
