/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-dropdown-button-content.h"

struct _KcDropDownButtonContent {
    AdwBin           parent_instance;

    char            *label_text;
};

G_DEFINE_FINAL_TYPE (KcDropDownButtonContent, kc_dropdown_button_content, ADW_TYPE_BIN)

static void
kc_dropdown_button_content_dispose (GObject *object)
{
    KcDropDownButtonContent *self = KC_DROPDOWN_BUTTON_CONTENT (object);

    // Unparent and also result to unbind label-text property with the label
    adw_bin_set_child (ADW_BIN (self), NULL);

    g_clear_pointer (&(self->label_text), g_free);

    G_OBJECT_CLASS (kc_dropdown_button_content_parent_class)->dispose (object);
}

static void
kc_dropdown_button_content_class_init (KcDropDownButtonContentClass *class)
{
    GObjectClass *object_class = G_OBJECT_CLASS (class);

    object_class->dispose = kc_dropdown_button_content_dispose;
}

static void
kc_dropdown_button_content_init (KcDropDownButtonContent *self)
{
    GtkWidget *label;

    self->label_text = NULL;

    label = gtk_label_new (self->label_text);
    gtk_label_set_xalign (GTK_LABEL (label), 0);
    gtk_label_set_ellipsize (GTK_LABEL (label), PANGO_ELLIPSIZE_END);

    g_object_bind_property (G_OBJECT (self), "label-text", label, "label", G_BINDING_DEFAULT);

    adw_bin_set_child (ADW_BIN (self), label);
}

void
kc_dropdown_button_content_set_label_text (KcDropDownButtonContent *self, const char *label_text)
{
    g_return_if_fail (KC_IS_DROPDOWN_BUTTON_CONTENT (self));

    if (g_strcmp0 (self->label_text, label_text) == 0) {
        return;
    }

    self->label_text = g_strdup (label_text);
}

KcDropDownButtonContent *
kc_dropdown_button_content_new (void)
{
    return g_object_new (KC_TYPE_DROPDOWN_BUTTON_CONTENT,
                         NULL);
}
