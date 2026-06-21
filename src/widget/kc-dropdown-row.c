/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-dropdown-row.h"

/**
 * KcDropDownRow:
 *
 * A row of a dropdown with a title and description text.
 *
 * <picture>
 *   <img src="example_drop_down_row.png" alt="example image of DropDownRow">
 * </picture>
 */

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
kc_dropdown_row_class_init (KcDropDownRowClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->dispose = kc_dropdown_row_dispose;
}

static void
kc_dropdown_row_init (KcDropDownRow *self)
{
    gtk_orientable_set_orientation (GTK_ORIENTABLE (self), GTK_ORIENTATION_VERTICAL);
    gtk_box_set_spacing (GTK_BOX (self), 2);

    self->title = gtk_label_new (NULL);
    gtk_widget_set_hexpand (self->title, TRUE);
    gtk_widget_add_css_class (self->title, "heading");
    gtk_label_set_width_chars (GTK_LABEL (self->title), 25);
    gtk_label_set_wrap (GTK_LABEL (self->title), TRUE);
    gtk_label_set_xalign (GTK_LABEL (self->title), 0);

    self->description = gtk_label_new (NULL);
    gtk_widget_set_hexpand (self->description, TRUE);
    gtk_widget_add_css_class (self->description, "dim-label");
    gtk_label_set_width_chars (GTK_LABEL (self->description), 25);
    gtk_label_set_wrap (GTK_LABEL (self->description), TRUE);
    gtk_label_set_xalign (GTK_LABEL (self->description), 0);

    gtk_box_append (GTK_BOX (self), self->title);
    gtk_box_append (GTK_BOX (self), self->description);
}

/**
 * kc_dropdown_row_get_title:
 * @self: a `KcDropDownRow`
 *
 * Gets title text of the row for @self.
 *
 * Returns: (nullable) (transfer none): title text of the row
 */
const char *
kc_dropdown_row_get_title (KcDropDownRow *self)
{
    g_return_val_if_fail (KC_IS_DROPDOWN_ROW (self), NULL);

    return gtk_label_get_label (GTK_LABEL (self->title));
}

/**
 * kc_dropdown_row_set_title:
 * @self: a `KcDropDownRow`
 * @title: (nullable) (transfer none): title text of the row
 *
 * Sets title text of the row for @self.
 */
void
kc_dropdown_row_set_title (KcDropDownRow *self,
                           const char    *title)
{
    g_return_if_fail (KC_IS_DROPDOWN_ROW (self));

    gtk_label_set_label (GTK_LABEL (self->title), title);
}

/**
 * kc_dropdown_row_get_description:
 * @self: a `KcDropDownRow`
 *
 * Gets description text of the row for @self.
 *
 * Returns: (nullable) (transfer none): description text of the row
 */
const char *
kc_dropdown_row_get_description (KcDropDownRow *self)
{
    g_return_val_if_fail (KC_IS_DROPDOWN_ROW (self), NULL);

    return gtk_label_get_label (GTK_LABEL (self->description));
}

/**
 * kc_dropdown_row_set_description:
 * @self: a `KcDropDownRow`
 * @description: (nullable) (transfer none): description text of the row
 *
 * Sets description text of the row for @self.
 */
void
kc_dropdown_row_set_description (KcDropDownRow *self,
                                 const char    *description)
{
    g_return_if_fail (KC_IS_DROPDOWN_ROW (self));

    gtk_label_set_label (GTK_LABEL (self->description), description);
}

/**
 * kc_dropdown_row_new:
 *
 * Creates a new `KcDropDownRow`.
 *
 * Returns: (transfer full): the newly created `KcDropDownRow`
 */
KcDropDownRow *
kc_dropdown_row_new (void)
{
    return g_object_new (KC_TYPE_DROPDOWN_ROW,
                         NULL);
}
