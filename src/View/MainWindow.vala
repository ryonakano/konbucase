/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    // Main menu model
    public Menu main_menu { get; private set; }

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

        var style_submenu = new Menu ();
        style_submenu.append (_("S_ystem"), "app.color-scheme(\"default\")");
        style_submenu.append (_("_Light"), "app.color-scheme(\"force-light\")");
        style_submenu.append (_("_Dark"), "app.color-scheme(\"force-dark\")");

        main_menu = new Menu ();
        main_menu.append_submenu (_("_Style"), style_submenu);
        main_menu.append (_("Keyboard Shortcuts"), "win.show-help-overlay");
        // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
        if (!Application.IS_ON_PANTHEON) {
            ///TRANSLATORS: Do NOT translate the phrase "KonbuCase"; it's the name of the app which is a proper noun.
            main_menu.append (_("_About KonbuCase"), "app.about");
        }

        // The action users most frequently take is to input the source text.
        // So, forcus to the source view by default.
        source_pane.get_source_view ().grab_focus ();

        // Perform conversion when:
        //
        //  * case type of the source text is changed
        //  * case type of the result text is changed
        //  * the source text is changed
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
