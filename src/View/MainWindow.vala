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
        style_submenu.append (_("S_ystem"), "app.color-scheme('%s')".printf (Define.ColorScheme.DEFAULT));
        style_submenu.append (_("_Light"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_LIGHT));
        style_submenu.append (_("_Dark"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_DARK));

        var main_menu = new Menu ();
        main_menu.append_submenu (_("_Style"), style_submenu);
        main_menu.append (_("_Keyboard Shortcuts"), "win.show-help-overlay");
        // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
        if (!Application.IS_ON_PANTHEON) {
            ///TRANSLATORS: %s will be replaced by the app name
            main_menu.append (_("_About %s").printf (Define.APP_NAME), "app.about");
        }

        var menu_button = new Gtk.MenuButton () {
            tooltip_text = _("Main Menu"),
            icon_name = "open-menu",
            menu_model = main_menu,
            primary = true
        };

        var header = new Adw.HeaderBar ();
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

        var content_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        content_box.append (source_pane);
        content_box.append (separator);
        content_box.append (result_pane);

        overlay = new Adw.ToastOverlay () {
            child = content_box
        };

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (header);
        toolbar_view.set_content (overlay);

        content = toolbar_view;
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
