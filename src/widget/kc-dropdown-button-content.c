/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-dropdown-button-content.h"

enum {
    PROP_0,

    PROP_LABEL_TEXT,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

struct _KcDropDownButtonContent {
    AdwBin           parent_instance;

    char            *label_text;
};

G_DEFINE_FINAL_TYPE (KcDropDownButtonContent, kc_dropdown_button_content, ADW_TYPE_BIN)

static void
kc_dropdown_button_content_get_property (GObject       *object,
                                         guint          prop_id,
                                         GValue        *value,
                                         GParamSpec    *pspec)
{
    KcDropDownButtonContent *self = KC_DROPDOWN_BUTTON_CONTENT (object);

    switch (prop_id) {
    case PROP_LABEL_TEXT:
        g_value_set_string (value, self->label_text);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_dropdown_button_content_set_property (GObject       *object,
                                         guint          prop_id,
                                         const GValue  *value,
                                         GParamSpec    *pspec)
{
    KcDropDownButtonContent *self = KC_DROPDOWN_BUTTON_CONTENT (object);

    switch (prop_id) {
    case PROP_LABEL_TEXT:
        g_clear_pointer (&(self->label_text), g_free);
        self->label_text = g_strdup (g_value_get_string (value));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

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
kc_dropdown_button_content_class_init (KcDropDownButtonContentClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->get_property = kc_dropdown_button_content_get_property;
    object_class->set_property = kc_dropdown_button_content_set_property;
    object_class->dispose = kc_dropdown_button_content_dispose;

    props[PROP_LABEL_TEXT] =
        g_param_spec_string ("label-text", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);
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
