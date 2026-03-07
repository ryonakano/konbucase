/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * The app window.
 */
public class MainWindow : Adw.ApplicationWindow {
    /**
     * A widget showing in-app notification above its content.
     */
    private Adw.ToastOverlay overlay;

    /**
     * Creates a new {@link MainWindow}.
     *
     * @param app   a {@link Application} to be associated with ``this``
     *
     * @return      a new {@link MainWindow}
     */
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
        main_menu.append (_("_Keyboard Shortcuts"), "win.show-help-overlay");
        // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
        if (!Util.is_on_pantheon ()) {
            ///TRANSLATORS: %s will be replaced by the app name
            main_menu.append (_("_About %s").printf (Config.APP_NAME), "app.about");
        }

        var swap_button = new Gtk.Button.from_icon_name ("media-playlist-repeat") {
            ///TRANSLATORS: Tooltip text of a button to swap case and text of input and output
            tooltip_text = _("Quick Swap"),
        };

        var menu_button = new Gtk.MenuButton () {
            tooltip_text = _("Main Menu"),
            icon_name = "open-menu",
            menu_model = main_menu,
            primary = true,
        };

        var header = new Adw.HeaderBar ();
        header.pack_start (swap_button);
        header.pack_end (menu_button);

        var main_content = new Widget.MainContent ();

        // Responsive design; change orientation to vertical on smaller window width
        var content_breakpoint = new Adw.Breakpoint (
            new Adw.BreakpointCondition.length (Adw.BreakpointConditionLengthType.MAX_WIDTH, 650, Adw.LengthUnit.SP)
        );
        content_breakpoint.add_setter (main_content, "orientation", Gtk.Orientation.VERTICAL);
        add_breakpoint (content_breakpoint);

        overlay = new Adw.ToastOverlay () {
            child = main_content,
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = overlay,
        };
        toolbar_view.add_top_bar (header);

        content = toolbar_view;
        width_request = 360;
        height_request = 400;
        title = Config.APP_NAME;

        swap_button.clicked.connect (() => {
            main_content.swap ();
        });

        main_content.text_copied.connect (() => {
            show_toast (N_("Text copied!"));
        });
    }

    /**
     * Present a toast, an in-app notification.
     *
     * @param title     the title of the toast
     */
    private void show_toast (string title) {
        var toast = new Adw.Toast (_(title));
        overlay.add_toast (toast);
    }
}
