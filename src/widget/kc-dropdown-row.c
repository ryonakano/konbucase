/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-dropdown-row.h"

struct _KcDropDownRow {
    GtkBox          parent_instance;

    GtkWidget       *title;
    GtkWidget       *description;
};
G_DEFINE_FINAL_TYPE (KcDropDownRow, kc_dropdown_row, GTK_TYPE_BOX)

static void
kc_dropdown_row_dispose (GObject *object)
{
    KcDropDownRow *self = KC_DROPDOWN_ROW (object);

    gtk_box_remove (GTK_BOX (self), self->title);
    gtk_box_remove (GTK_BOX (self), self->description);

    G_OBJECT_CLASS (kc_dropdown_row_parent_class)->dispose (object);
}

static void
kc_dropdown_row_class_init (KcDropDownRowClass *class)
{
    GObjectClass *object_class = G_OBJECT_CLASS (class);

    object_class->dispose = kc_dropdown_row_dispose;
}

static void
kc_dropdown_row_init (KcDropDownRow *self)
{
    GtkWidget *title;
    GtkWidget *description;

    gtk_orientable_set_orientation (GTK_ORIENTABLE (self), GTK_ORIENTATION_VERTICAL);
    gtk_box_set_spacing (GTK_BOX (self), 2);

    title = gtk_label_new (NULL);
    gtk_widget_set_hexpand (title, TRUE);
    gtk_widget_add_css_class (title, "heading");
    gtk_label_set_width_chars (GTK_LABEL (title), 25);
    gtk_label_set_wrap (GTK_LABEL (title), TRUE);
    gtk_label_set_xalign (GTK_LABEL (title), 0);

    description = gtk_label_new (NULL);
    gtk_widget_set_hexpand (description, TRUE);
    gtk_widget_add_css_class (description, "dim-label");
    gtk_label_set_width_chars (GTK_LABEL (description), 25);
    gtk_label_set_wrap (GTK_LABEL (description), TRUE);
    gtk_label_set_xalign (GTK_LABEL (description), 0);

    gtk_box_append (GTK_BOX (self), title);
    self->title = title;

    gtk_box_append (GTK_BOX (self), description);
    self->description = description;
}

void
kc_dropdown_row_set_title (KcDropDownRow   *self,
                           const char      *str)
{
    g_return_if_fail (KC_IS_DROPDOWN_ROW (self));

    gtk_label_set_label (GTK_LABEL (self->title), str);
}

const char *
kc_dropdown_row_get_title (KcDropDownRow   *self)
{
    g_return_val_if_fail (KC_IS_DROPDOWN_ROW (self), NULL);

    return gtk_label_get_label (GTK_LABEL (self->title));
}

void
kc_dropdown_row_set_description (KcDropDownRow   *self,
                                 const char      *str)
{
    g_return_if_fail (KC_IS_DROPDOWN_ROW (self));

    gtk_label_set_label (GTK_LABEL (self->description), str);
}

const char *
kc_dropdown_row_get_description (KcDropDownRow   *self)
{
    g_return_val_if_fail (KC_IS_DROPDOWN_ROW (self), NULL);

    return gtk_label_get_label (GTK_LABEL (self->description));
}

KcDropDownRow *
kc_dropdown_row_new (void)
{
    return g_object_new (KC_TYPE_DROPDOWN_ROW,
                         NULL);
}
