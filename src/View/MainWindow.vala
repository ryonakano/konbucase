/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/View/MainWindow.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned ComboEntry source_combo_entry;
    [GtkChild]
    private unowned ComboEntry result_combo_entry;
    [GtkChild]
    private unowned Granite.Toast toast;

    private MainWindowModel model;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        model = new MainWindowModel ();

        source_combo_entry.get_source_view ().grab_focus ();

        source_combo_entry.dropdown_changed.connect (() => {
            do_convert ();
        });
        result_combo_entry.dropdown_changed.connect (() => {
            do_convert ();
        });

        source_combo_entry.text_changed.connect (() => {
            do_convert ();
        });

        source_combo_entry.text_copied.connect (show_toast);
        result_combo_entry.text_copied.connect (show_toast);
    }

    private void do_convert () {
        model.set_case_type (source_combo_entry.case_type, result_combo_entry.case_type);
        result_combo_entry.text = model.convert_case (source_combo_entry.text);
    }

    private void show_toast () {
        toast.send_notification ();
    }
}
