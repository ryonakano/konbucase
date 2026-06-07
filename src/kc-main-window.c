/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "config.h"

#include <glib/gi18n.h>

#include "kc-main-window.h"

#include "kc-util.h"
#include "kc-common.h"

struct _KcMainWindow {
    AdwApplicationWindow         parent_instance;

    AdwToastOverlay             *overlay;
};

G_DEFINE_FINAL_TYPE (KcMainWindow, kc_main_window, ADW_TYPE_APPLICATION_WINDOW)

static void
kc_main_window_dispose (GObject *object)
{
    G_OBJECT_CLASS (kc_main_window_parent_class)->dispose (object);
}

static void
kc_main_window_class_init (KcMainWindowClass *class)
{
    GObjectClass *object_class = G_OBJECT_CLASS (class);

    object_class->dispose = kc_main_window_dispose;
}

static void
kc_main_window_init (KcMainWindow *self)
{
    g_autoptr(GMenu) style_submenu = NULL;
    g_autoptr(GMenu) main_menu = NULL;
    g_autofree char *about_label = NULL;
    GtkWidget *swap_button;
    GtkWidget *menu_button;
    GtkWidget *header;
    GtkWidget *toolbar_view;

    // Distinct development build visually
    if (g_str_has_prefix (APP_ID, ".Devel")) {
        gtk_widget_add_css_class (GTK_WIDGET (self), "devel");
    }

    style_submenu = g_menu_new ();
    g_menu_append (style_submenu, N_("S_ystem"), "app.color-scheme('" KC_COLOR_SCHEME_DEFAULT "')");
    g_menu_append (style_submenu, N_("_Light"), "app.color-scheme('" KC_COLOR_SCHEME_FORCE_LIGHT "')");
    g_menu_append (style_submenu, N_("_Dark"), "app.color-scheme('" KC_COLOR_SCHEME_FORCE_DARK "')");

    main_menu = g_menu_new ();
    g_menu_append_submenu (main_menu, N_("_Style"), G_MENU_MODEL (style_submenu));
    g_menu_append (main_menu, N_("_Keyboard Shortcuts"), "win.show-help-overlay");
    // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
    if (!kc_util_is_pantheon ()) {
        ///TRANSLATORS: %s will be replaced by the app name
        about_label = g_strdup_printf (N_("_About %s"), APP_NAME);
        g_menu_append (main_menu, about_label, "app.about");
    }

    swap_button = gtk_button_new_from_icon_name ("media-playlist-repeat");
    ///TRANSLATORS: Tooltip text of a button to swap case and text of input and output
    gtk_widget_set_tooltip_text (swap_button, N_("Quick Swap"));

    menu_button = gtk_menu_button_new ();
    gtk_widget_set_tooltip_text (menu_button, N_("Main Menu"));
    gtk_menu_button_set_icon_name (GTK_MENU_BUTTON (menu_button), "open-menu");
    gtk_menu_button_set_menu_model (GTK_MENU_BUTTON (menu_button), G_MENU_MODEL (main_menu));
    gtk_menu_button_set_primary (GTK_MENU_BUTTON (menu_button), TRUE);

    header = adw_header_bar_new ();
    adw_header_bar_pack_start (ADW_HEADER_BAR (header), swap_button);
    adw_header_bar_pack_end (ADW_HEADER_BAR (header), menu_button);

    // TODO
#if 0
        var main_view = new View.MainView ();

        // Responsive design; change orientation to vertical on smaller window width
        var content_breakpoint = new Adw.Breakpoint (
            new Adw.BreakpointCondition.length (Adw.BreakpointConditionLengthType.MAX_WIDTH, 750, Adw.LengthUnit.SP)
        );
        content_breakpoint.add_setter (main_view, "orientation", Gtk.Orientation.VERTICAL);
        add_breakpoint (content_breakpoint);

        overlay = new Adw.ToastOverlay () {
            child = main_view,
        };
#endif

    toolbar_view = adw_toolbar_view_new ();
    adw_toolbar_view_add_top_bar (ADW_TOOLBAR_VIEW (toolbar_view), header);

    gtk_widget_set_size_request (GTK_WIDGET (self), 360, 400);
    gtk_window_set_title (GTK_WINDOW (self), APP_NAME);
    adw_application_window_set_content (ADW_APPLICATION_WINDOW (self), toolbar_view);
}

KcMainWindow *
kc_main_window_new (void)
{
    return g_object_new (KC_TYPE_MAIN_WINDOW,
                         NULL);
}
