/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned Granite.Toast toast;

    [GtkChild]
    private unowned ComboEntry source_combo_entry;
    [GtkChild]
    private unowned ComboEntry result_combo_entry;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        source_combo_entry.get_source_view ().grab_focus ();

        source_combo_entry.text_copied.connect (show_toast);
        result_combo_entry.text_copied.connect (show_toast);
    }

    private void show_toast () {
        toast.send_notification ();
    }
}
