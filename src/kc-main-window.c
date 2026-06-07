/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "config.h"

#include "kc-main-window.h"

#include <glib/gi18n.h>

#include "kc-common.h"
#include "kc-main-view.h"
#include "kc-util.h"

struct _KcMainWindow {
    AdwApplicationWindow         parent_instance;
};

G_DEFINE_FINAL_TYPE (KcMainWindow, kc_main_window, ADW_TYPE_APPLICATION_WINDOW)

/**
 * kc_main_window_show_toast:
 * @overlay: (transfer none): a #AdwToastOverlay to show a toast on
 * @title: (transfer none): the title of the toast
 *
 * Presents a toast, an in-app notification.
 */
static void
kc_main_window_show_toast (AdwToastOverlay  *overlay,
                           const gchar      *title)
{
    g_autoptr(AdwToast) toast;

    toast = adw_toast_new (_(title));
    adw_toast_overlay_add_toast (overlay, toast);
}

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
    KcMainView *main_view;
    AdwBreakpointCondition *content_bpcond;
    AdwBreakpoint *content_breakpoint;
    GValue orientation = G_VALUE_INIT;
    GtkWidget *overlay;
    GtkWidget *toolbar_view;

    // Distinct development build visually
    if (g_str_has_prefix (APP_ID, ".Devel")) {
        gtk_widget_add_css_class (GTK_WIDGET (self), "devel");
    }

    style_submenu = g_menu_new ();
    g_menu_append (style_submenu, _("S_ystem"), "app.color-scheme('" KC_COLOR_SCHEME_DEFAULT "')");
    g_menu_append (style_submenu, _("_Light"), "app.color-scheme('" KC_COLOR_SCHEME_FORCE_LIGHT "')");
    g_menu_append (style_submenu, _("_Dark"), "app.color-scheme('" KC_COLOR_SCHEME_FORCE_DARK "')");

    main_menu = g_menu_new ();
    g_menu_append_submenu (main_menu, _("_Style"), G_MENU_MODEL (style_submenu));
    g_menu_append (main_menu, _("_Keyboard Shortcuts"), "win.show-help-overlay");
    // Pantheon prefers AppCenter instead of an about dialog for app details, so prevent it from being shown on Pantheon
    if (!kc_util_is_pantheon ()) {
        ///TRANSLATORS: %s will be replaced by the app name
        about_label = g_strdup_printf (_("_About %s"), APP_NAME);
        g_menu_append (main_menu, about_label, "app.about");
    }

    swap_button = gtk_button_new_from_icon_name ("media-playlist-repeat");
    ///TRANSLATORS: Tooltip text of a button to swap case and text of input and output
    gtk_widget_set_tooltip_text (swap_button, _("Quick Swap"));

    menu_button = gtk_menu_button_new ();
    gtk_widget_set_tooltip_text (menu_button, _("Main Menu"));
    gtk_menu_button_set_icon_name (GTK_MENU_BUTTON (menu_button), "open-menu");
    gtk_menu_button_set_menu_model (GTK_MENU_BUTTON (menu_button), G_MENU_MODEL (main_menu));
    gtk_menu_button_set_primary (GTK_MENU_BUTTON (menu_button), TRUE);

    header = adw_header_bar_new ();
    adw_header_bar_pack_start (ADW_HEADER_BAR (header), swap_button);
    adw_header_bar_pack_end (ADW_HEADER_BAR (header), menu_button);

    main_view = kc_main_view_new ();

    // Responsive design; change orientation to vertical on smaller window width
    content_bpcond = adw_breakpoint_condition_new_length (ADW_BREAKPOINT_CONDITION_MAX_WIDTH, 750, ADW_LENGTH_UNIT_SP);
    content_breakpoint = adw_breakpoint_new (content_bpcond);

    g_value_init (&orientation, G_TYPE_INT);
    g_value_set_int (&orientation, GTK_ORIENTATION_VERTICAL);
    adw_breakpoint_add_setter (content_breakpoint, G_OBJECT (main_view), "orientation", &orientation);
    g_value_unset (&orientation);

    adw_application_window_add_breakpoint (ADW_APPLICATION_WINDOW (self), content_breakpoint);

    overlay = adw_toast_overlay_new ();
    adw_toast_overlay_set_child (ADW_TOAST_OVERLAY (overlay), GTK_WIDGET (main_view));

    toolbar_view = adw_toolbar_view_new ();
    adw_toolbar_view_add_top_bar (ADW_TOOLBAR_VIEW (toolbar_view), header);
    adw_toolbar_view_set_content (ADW_TOOLBAR_VIEW (toolbar_view), overlay);

    gtk_widget_set_size_request (GTK_WIDGET (self), 360, 400);
    gtk_window_set_title (GTK_WINDOW (self), APP_NAME);
    adw_application_window_set_content (ADW_APPLICATION_WINDOW (self), toolbar_view);

    // TODO
#if 0
        swap_button.clicked.connect (() => {
            main_view.swap ();
        });

        main_view.text_copied.connect (() => {
            show_toast (N_("Text copied!"));
        });
#endif
}

KcMainWindow *
kc_main_window_new (void)
{
    return g_object_new (KC_TYPE_MAIN_WINDOW,
                         NULL);
}
