/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    private Adw.ToastOverlay overlay;
    private View.Pane.SourcePane source_pane;
    private View.Pane.ResultPane result_pane;

    private ChCase.Converter converter;

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
        style_submenu.append (_("S_ystem"), "app.color-scheme('%s')".printf (Define.ColorScheme.DEFAULT));
        style_submenu.append (_("_Light"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_LIGHT));
        style_submenu.append (_("_Dark"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_DARK));

        var main_menu = new Menu ();
        main_menu.append_submenu (_("_Style"), style_submenu);
        main_menu.append (_("_Keyboard Shortcuts"), "app.shortcuts");
        // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
        if (!Util.is_on_pantheon ()) {
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

        source_pane = new View.Pane.SourcePane ();

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL) {
            vexpand = true
        };

        result_pane = new View.Pane.ResultPane ();

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
        title = Define.APP_NAME;

        converter = new ChCase.Converter ();

        // The action users most frequently take is to input the source text.
        // So, forcus to the source view by default.
        source_pane.focus_source_view ();

        // Perform conversion when:
        //
        //  * case type of the source text is changed
        //  * case type of the result text is changed
        //  * the source text is changed
        //  * the window is initialized
        source_pane.dropdown_changed.connect (() => {
            result_pane.text = do_convert (source_pane.case_type, source_pane.text, result_pane.case_type);
        });
        result_pane.dropdown_changed.connect (() => {
            result_pane.text = do_convert (source_pane.case_type, source_pane.text, result_pane.case_type);
        });
        source_pane.notify["text"].connect (() => {
            result_pane.text = do_convert (source_pane.case_type, source_pane.text, result_pane.case_type);
        });
        result_pane.text = do_convert (source_pane.case_type, source_pane.text, result_pane.case_type);

        source_pane.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (source_pane.text);
            toast_copied ();
        });
        result_pane.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (result_pane.text);
            toast_copied ();
        });
    }

    private void toast_copied () {
        show_toast (N_("Text copied!"));
    }

    private void show_toast (string text) {
        var toast = new Adw.Toast (_(text));
        overlay.add_toast (toast);
    }

    /**
     * Perform conversion of {@link source_text} and return result text.
     *
     * @param source_case case type of source text
     * @param source_text text that is converted
     * @param result_case case type of result text
     *
     * @return text after conversion
     */
    private string do_convert (Define.CaseType source_case, string source_text, Define.CaseType result_case) {
        string result_text;

        converter.source_case = Util.to_chcase_case (source_case);
        converter.result_case = Util.to_chcase_case (result_case);

        result_text = converter.convert_case (source_text);

        return result_text;
    }
}
