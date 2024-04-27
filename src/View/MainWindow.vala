/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned ComboEntry source_combo_entry;
    [GtkChild]
    private unowned ComboEntry result_combo_entry;
    [GtkChild]
    private unowned Granite.Toast toast;

    [GtkChild]
    private unowned ComboEntryModel source_model;
    [GtkChild]
    private unowned ComboEntryModel result_model;
    [GtkChild]
    private unowned MainWindowModel window_model;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        source_combo_entry.get_source_view ().grab_focus ();

        source_combo_entry.dropdown_changed.connect (() => {
            window_model.do_convert ();
        });
        result_combo_entry.dropdown_changed.connect (() => {
            window_model.do_convert ();
        });

        source_model.notify["text"].connect (() => {
            window_model.do_convert ();
        });

        source_combo_entry.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (source_model.text);
            show_toast ();
        });
        result_combo_entry.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (result_model.text);
            show_toast ();
        });
    }

    private void show_toast () {
        toast.send_notification ();
    }
}
