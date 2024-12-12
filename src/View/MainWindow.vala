/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    private Adw.ToastOverlay overlay;

    public MainWindow (Application app) {
        Object (
            application: app,
            title: "KonbuCase"
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

        var main_menu = new Menu ();
        main_menu.append_submenu (_("_Style"), style_submenu);
        main_menu.append (_("Keyboard Shortcuts"), "win.show-help-overlay");
        // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
        if (!Application.IS_ON_PANTHEON) {
            ///TRANSLATORS: Do NOT translate the phrase "KonbuCase"; it's the name of the app which is a proper noun.
            main_menu.append (_("_About KonbuCase"), "app.about");
        }

        var menu_button = new Gtk.MenuButton () {
            tooltip_text = _("Main Menu"),
            icon_name = "open-menu",
            menu_model = main_menu,
            primary = true
        };

        var header = new Gtk.HeaderBar ();
        header.pack_end (menu_button);

        var source_model = new TextPaneModel (Define.TextType.SOURCE);
        var result_model = new TextPaneModel (Define.TextType.RESULT);
        var window_model = new MainWindowModel (source_model, result_model);

        var source_pane = new TextPane (
            source_model,
            _("Convert _From:"),
            true
        );

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            vexpand = true
        };

        var result_pane = new TextPane (
            result_model,
            _("Convert _To:"),
            // Make the text view uneditable, otherwise the app freezes
            false
        );

        var contnet_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        contnet_box.append (source_pane);
        contnet_box.append (separator);
        contnet_box.append (result_pane);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (header);
        main_box.append (contnet_box);

        overlay = new Adw.ToastOverlay () {
            child = main_box
        };

        content = overlay;
        width_request = 700;
        height_request = 500;

        // The action users most frequently take is to input the source text.
        // So, forcus to the source view by default.
        source_pane.focus_source_view ();

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
