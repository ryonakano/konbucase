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

/**
 * KcMainWindow:
 *
 * The app window.
 */

struct _KcMainWindow {
    AdwApplicationWindow         parent_instance;

    GtkWidget                    overlay;
};

G_DEFINE_FINAL_TYPE (KcMainWindow, kc_main_window, ADW_TYPE_APPLICATION_WINDOW)

static void
kc_main_window_show_toast (AdwToastOverlay *overlay)
{
    AdwToast *toast;

    toast = adw_toast_new (_("Text copied!"));
    adw_toast_overlay_add_toast (overlay, toast);
}

static void
kc_main_window_dispose (GObject *object)
{
    KcMainWindow *self = KC_MAIN_WINDOW (object);

    gtk_widget_dispose_template (GTK_WIDGET (self), KC_TYPE_MAIN_WINDOW);

    G_OBJECT_CLASS (kc_main_window_parent_class)->dispose (object);
}

static void
kc_main_window_class_init (KcMainWindowClass *klass)
{
    GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    gtk_widget_class_set_template_from_resource (widget_class, "/com/github/ryonakano/konbucase/kc-main-window.ui");
    gtk_widget_class_bind_template_child (widget_class, KcMainWindow, overlay);
    //gtk_widget_class_bind_template_callback (widget_class, notify_is_active_cb);

    object_class->dispose = kc_main_window_dispose;
}

static void
kc_main_window_init (KcMainWindow *self)
{
    GtkWidget *swap_button;
    GtkWidget *menu_button;
    KcMainView *main_view;
    GtkWidget *toolbar_view;

    gtk_widget_init_template (GTK_WIDGET (self));

    // Distinct development build visually
    if (g_str_has_suffix (APP_ID, ".Devel")) {
        gtk_widget_add_css_class (GTK_WIDGET (self), "devel");
    }

    //main_view = kc_main_view_new ();

    //g_signal_connect_swapped (swap_button, "clicked", G_CALLBACK (kc_main_view_swap), main_view);

    //g_signal_connect_swapped (main_view, "text-copied", G_CALLBACK (kc_main_window_show_toast), overlay);
}

/**
 * kc_main_window_new:
 * @app: a #KcApplication to be associated with #KcMainWindow
 *
 * Creates a new #KcMainWindow.
 *
 * Returns: (transfer full): the newly created #KcMainWindow
 */
KcMainWindow *
kc_main_window_new (KcApplication *app)
{
    return g_object_new (KC_TYPE_MAIN_WINDOW,
                         "application", G_APPLICATION (app),
                         nullptr);
}
