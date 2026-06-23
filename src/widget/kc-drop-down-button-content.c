/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-drop-down-button-content.h"

#include <pango/pango.h>

/**
 * KcDropDownButtonContent:
 *
 * The item in the button of a dropdown.
 *
 * The most significant difference with the default button content of a #GtkDropDown
 * is that the label in the item is ellipsized if its text is too long.
 *
 * <picture>
 *   <img src="example_drop_down_button_content.png" alt="example image of DropDownButtonContent">
 * </picture>
 */

enum {
    PROP_0,

    PROP_LABEL_TEXT,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

struct _KcDropDownButtonContent {
    AdwBin      parent_instance;

    gchar      *label_text;
};

G_DEFINE_FINAL_TYPE (KcDropDownButtonContent, kc_drop_down_button_content, ADW_TYPE_BIN)

static void
kc_drop_down_button_content_get_property (GObject    *object,
                                          guint       prop_id,
                                          GValue     *value,
                                          GParamSpec *pspec)
{
    KcDropDownButtonContent *self = KC_DROP_DOWN_BUTTON_CONTENT (object);

    switch (prop_id) {
    case PROP_LABEL_TEXT:
        g_value_set_string (value, kc_drop_down_button_content_get_label_text (self));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_drop_down_button_content_set_property (GObject      *object,
                                          guint         prop_id,
                                          const GValue *value,
                                          GParamSpec   *pspec)
{
    KcDropDownButtonContent *self = KC_DROP_DOWN_BUTTON_CONTENT (object);

    switch (prop_id) {
    case PROP_LABEL_TEXT:
        kc_drop_down_button_content_set_label_text (self, g_value_get_string (value));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_drop_down_button_content_dispose (GObject *object)
{
    KcDropDownButtonContent *self = KC_DROP_DOWN_BUTTON_CONTENT (object);

    adw_bin_set_child (ADW_BIN (self), NULL);

    g_clear_pointer (&self->label_text, g_free);

    G_OBJECT_CLASS (kc_drop_down_button_content_parent_class)->dispose (object);
}

static void
kc_drop_down_button_content_class_init (KcDropDownButtonContentClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->get_property = kc_drop_down_button_content_get_property;
    object_class->set_property = kc_drop_down_button_content_set_property;
    object_class->dispose = kc_drop_down_button_content_dispose;

    /**
     * KcDropDownButtonContent:label-text:
     *
     * The label text of the item.
     */
    props[PROP_LABEL_TEXT] =
        g_param_spec_string ("label-text", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    g_object_class_install_properties (object_class, N_PROPS, props);
}

static void
kc_drop_down_button_content_init (KcDropDownButtonContent *self)
{
    GtkWidget *label;

    self->label_text = NULL;

    label = gtk_label_new (self->label_text);
    gtk_label_set_xalign (GTK_LABEL (label), 0);
    gtk_label_set_ellipsize (GTK_LABEL (label), PANGO_ELLIPSIZE_END);

    g_object_bind_property (G_OBJECT (self), "label-text", label, "label", G_BINDING_DEFAULT);

    adw_bin_set_child (ADW_BIN (self), label);
}

/**
 * kc_drop_down_button_content_get_label_text:
 * @self: a `KcDropDownButtonContent`
 *
 * Gets the label text of the item for @self.
 *
 * Returns: (nullable) (transfer none): the label text of the item
 */
const char *
kc_drop_down_button_content_get_label_text (KcDropDownButtonContent *self)
{
    g_return_val_if_fail (KC_IS_DROP_DOWN_BUTTON_CONTENT (self), NULL);

    return self->label_text;
}

/**
 * kc_drop_down_button_content_set_label_text:
 * @self: a `KcDropDownButtonContent`
 * @label_text: (nullable) (transfer none): the label text of the item
 *
 * Sets the label text of the item for @self.
 */
void
kc_drop_down_button_content_set_label_text (KcDropDownButtonContent *self,
                                            const gchar             *label_text)
{
    g_return_if_fail (KC_IS_DROP_DOWN_BUTTON_CONTENT (self));

    if (g_strcmp0 (self->label_text, label_text) == 0) {
        return;
    }

    g_set_str (&self->label_text, label_text);

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_LABEL_TEXT]);
}

/**
 * kc_drop_down_button_content_new:
 *
 * Creates a new `KcDropDownButtonContent`.
 *
 * Returns: (transfer full): the newly created `KcDropDownButtonContent`
 */
KcDropDownButtonContent *
kc_drop_down_button_content_new (void)
{
    return g_object_new (KC_TYPE_DROP_DOWN_BUTTON_CONTENT,
                         NULL);
}
