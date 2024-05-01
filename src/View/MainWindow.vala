/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Adw.ToastOverlay overlay;
    [GtkChild]
    private unowned TextPane source_pane;
    [GtkChild]
    private unowned TextPane result_pane;

    [GtkChild]
    private unowned TextPaneModel source_model;
    [GtkChild]
    private unowned TextPaneModel result_model;
    [GtkChild]
    private unowned MainWindowModel window_model;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        // Distinct development build visually
        if (".Devel" in Config.APP_ID) {
            add_css_class ("devel");
        }

        source_pane.get_source_view ().grab_focus ();

        source_pane.dropdown_changed.connect (() => {
            window_model.do_convert ();
        });
        result_pane.dropdown_changed.connect (() => {
            window_model.do_convert ();
        });

        source_model.notify["text"].connect (() => {
            window_model.do_convert ();
        });

        source_pane.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (source_model.text);
            show_toast ();
        });
        result_pane.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (result_model.text);
            show_toast ();
        });
    }

    private void show_toast () {
        var toast = new Adw.Toast (_("Text copied!"));
        overlay.add_toast (toast);
    }
}
