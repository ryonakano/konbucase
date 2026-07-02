/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-text-area.h"

#include <gtksourceview/gtksource.h>

/**
 * KcTextArea:
 *
 * A widget that wraps a #GtkSourceView.
 *
 * <picture>
 *   <img src="example_text_area.png" alt="example image of TextArea">
 * </picture>
 */

enum {
    PROP_0,

    PROP_EDITABLE,
    PROP_TEXT,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

struct _KcTextArea {
    AdwBin              parent_instance;

    char               *text;
    GtkSourceBuffer    *buffer;
    GtkWidget          *source_view;
};

G_DEFINE_FINAL_TYPE (KcTextArea, kc_text_area, ADW_TYPE_BIN)

static gboolean
prefer_dark_to_style_scheme (GBinding     *binding,
                             const GValue *prefer_dark,
                             GValue       *style_scheme,
                             gpointer      user_data)
{
    gboolean _prefer_dark;
    GtkSourceStyleScheme *_style_scheme;
    GtkSourceStyleSchemeManager *style_scheme_manager = GTK_SOURCE_STYLE_SCHEME_MANAGER (user_data);

    _prefer_dark = g_value_get_boolean (prefer_dark);
    if (_prefer_dark) {
        _style_scheme = gtk_source_style_scheme_manager_get_scheme (style_scheme_manager, "solarized-dark");
    } else {
        _style_scheme = gtk_source_style_scheme_manager_get_scheme (style_scheme_manager, "solarized-light");
    }

    g_value_set_object (style_scheme, _style_scheme);

    return TRUE;
}

static void
kc_text_area_get_property (GObject    *object,
                           guint       prop_id,
                           GValue     *value,
                           GParamSpec *pspec)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    switch (prop_id) {
    case PROP_EDITABLE:
        g_value_set_boolean (value, kc_text_area_get_editable (self));
        break;
    case PROP_TEXT:
        g_value_take_string (value, kc_text_area_dup_text (self));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_text_area_set_property (GObject      *object,
                           guint         prop_id,
                           const GValue *value,
                           GParamSpec   *pspec)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    switch (prop_id) {
    case PROP_EDITABLE:
        kc_text_area_set_editable (self, g_value_get_boolean (value));
        break;
    case PROP_TEXT:
        kc_text_area_set_text (self, g_value_get_string (value));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_text_area_dispose (GObject *object)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    gtk_text_view_set_buffer (GTK_TEXT_VIEW (self->source_view), NULL);
    g_clear_object (&self->buffer);

    adw_bin_set_child (ADW_BIN (self), NULL);

    g_clear_pointer (&self->text, g_free);

    G_OBJECT_CLASS (kc_text_area_parent_class)->dispose (object);
}

static void
kc_text_area_class_init (KcTextAreaClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->get_property = kc_text_area_get_property;
    object_class->set_property = kc_text_area_set_property;
    object_class->dispose = kc_text_area_dispose;

    /**
     * KcTextArea:editable:
     *
     * Whether it's possible to modify text in the #GtkSourceView that `KcTextArea` wraps.
     */
    props[PROP_EDITABLE] =
        g_param_spec_boolean ("editable", NULL, NULL,
                              FALSE,
                              G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    /**
     * KcTextArea:text:
     *
     * Text in the #GtkSourceView that `KcTextArea` wraps.
     */
    props[PROP_TEXT] =
        g_param_spec_string ("text", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    g_object_class_install_properties (object_class, N_PROPS, props);
}

static void
kc_text_area_init (KcTextArea *self)
{
    GtkSourceStyleSchemeManager *style_scheme_manager;
    GtkSettings *gtk_settings;
    GtkWidget *scrolled;

    self->text = NULL;

    self->buffer = gtk_source_buffer_new (NULL);
    style_scheme_manager = gtk_source_style_scheme_manager_get_default ();
    gtk_settings = gtk_settings_get_default ();

    self->source_view = gtk_source_view_new_with_buffer (self->buffer);
    gtk_text_view_set_wrap_mode (GTK_TEXT_VIEW (self->source_view), GTK_WRAP_WORD_CHAR);
    gtk_widget_set_hexpand (GTK_WIDGET (self->source_view), TRUE);
    gtk_widget_set_vexpand (GTK_WIDGET (self->source_view), TRUE);

    scrolled = gtk_scrolled_window_new ();
    gtk_scrolled_window_set_child (GTK_SCROLLED_WINDOW (scrolled), self->source_view);

    adw_bin_set_child (ADW_BIN (self), scrolled);

    // Sync with buffer text
    g_object_bind_property (G_OBJECT (self->buffer), "text",
                            G_OBJECT (self), "text",
                            G_BINDING_BIDIRECTIONAL | G_BINDING_SYNC_CREATE);

    // Apply theme changes to the source view
    g_object_bind_property_full (G_OBJECT (gtk_settings), "gtk-application-prefer-dark-theme",
                                 G_OBJECT (self->buffer), "style-scheme",
                                 G_BINDING_DEFAULT | G_BINDING_SYNC_CREATE,
                                 prefer_dark_to_style_scheme,
                                 NULL,
                                 style_scheme_manager,
                                 NULL);
}

/**
 * kc_text_area_get_editable:
 * @self: a `KcCaseListItem`
 *
 * Gets whether it's possible to modify text in the #GtkSourceView that @self wraps.
 *
 * Returns: Whether it's possible to modify text in the #GtkSourceView that @self wraps
 */
gboolean
kc_text_area_get_editable (KcTextArea *self)
{
    g_return_val_if_fail (KC_IS_TEXT_AREA (self), FALSE);

    return gtk_text_view_get_editable (GTK_TEXT_VIEW (self->source_view));
}

/**
 * kc_text_area_set_editable:
 * @self: a `KcTextArea`
 * @editable: whether it's possible to modify text in the #GtkSourceView that @self wraps
 *
 * Sets whether it's possible to modify text in the #GtkSourceView that @self wraps.
 */
void
kc_text_area_set_editable (KcTextArea *self,
                           gboolean editable)
{
    gboolean _editable;

    g_return_if_fail (KC_IS_TEXT_AREA (self));

    _editable = kc_text_area_get_editable (self);
    if (_editable == editable) {
        return;
    }

    gtk_text_view_set_editable (GTK_TEXT_VIEW (self->source_view), editable);

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_EDITABLE]);
}

/**
 * kc_text_area_dup_text:
 * @self: a `KcCaseListItem`
 *
 * Gets a copy of text in the #GtkSourceView that @self wraps.
 *
 * Returns: (nullable) (transfer none): text in the #GtkSourceView that @self wraps
 */
char *
kc_text_area_dup_text (KcTextArea *self)
{
    g_return_val_if_fail (KC_IS_TEXT_AREA (self), NULL);

    return g_strdup (self->text);
}

/**
 * kc_text_area_set_text:
 * @self: a `KcTextArea`
 * @text: (nullable) (transfer none): text in the #GtkSourceView that @self wraps
 *
 * Sets text in the #GtkSourceView that @self wraps.
 */
void
kc_text_area_set_text (KcTextArea *self,
                       const char *text)
{
    g_return_if_fail (KC_IS_TEXT_AREA (self));

    if (g_strcmp0 (self->text, text) == 0) {
        return;
    }

    g_set_str (&self->text, text);

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_TEXT]);
}

/**
 * kc_text_area_clear_text:
 * @self: a `KcTextArea`
 *
 * Clears text in the #GtkSourceView that @self wraps.
 */
void
kc_text_area_clear_text (KcTextArea *self)
{
    kc_text_area_set_text (self, "");
}

/**
 * kc_text_area_grab_focus:
 * @self: a `KcTextArea`
 *
 * Causes the #GtkSourceView that @self wraps to have the keyboard focus for the app window.
 */
void
kc_text_area_grab_focus (KcTextArea *self)
{
    g_return_if_fail (KC_IS_TEXT_AREA (self));

    gtk_widget_grab_focus (GTK_WIDGET (self->source_view));
}

/**
 * kc_text_area_new:
 * @editable: whether it's possible to modify text in the #GtkSourceView that `KcTextArea` wraps
 *
 * Creates a new `KcTextArea`.
 *
 * Returns: (transfer full): the newly created `KcTextArea`
 */
KcTextArea *
kc_text_area_new (gboolean editable)
{
    return g_object_new (KC_TYPE_TEXT_AREA,
                         "editable", editable,
                         NULL);
}
