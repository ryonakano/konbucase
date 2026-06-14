/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-main-view.h"

#include "kc-text-area.h"

struct _KcMainView {
    GtkBox              parent_instance;
};

G_DEFINE_FINAL_TYPE (KcMainView, kc_main_view, GTK_TYPE_BOX)

static void
kc_main_view_dispose (GObject *object)
{
    G_OBJECT_CLASS (kc_main_view_parent_class)->dispose (object);
}

static void
kc_main_view_class_init (KcMainViewClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->dispose = kc_main_view_dispose;
}

static void
kc_main_view_init (KcMainView *self)
{
    gtk_box_append (GTK_BOX (self), GTK_WIDGET (kc_text_area_new (TRUE)));
    gtk_box_append (GTK_BOX (self), gtk_label_new ("Label 2"));
}

KcMainView *
kc_main_view_new (void)
{
    return g_object_new (KC_TYPE_MAIN_VIEW,
                         NULL);
}
