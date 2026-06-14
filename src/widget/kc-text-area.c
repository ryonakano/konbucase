/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-text-area.h"

#include <gtksourceview/gtksource.h>

enum {
    PROP_0,

    PROP_EDITABLE,
    PROP_TEXT,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

struct _KcTextArea {
    AdwBin              parent_instance;

    gboolean            editable;
    GtkSourceBuffer    *buffer;
    const char         *text;
    GtkWidget          *source_view;
};

G_DEFINE_FINAL_TYPE (KcTextArea, kc_text_area, ADW_TYPE_BIN)

static gboolean
prefer_dark_to_style_scheme (GBinding      *binding,
                             const GValue  *prefer_dark,
                             GValue        *style_scheme,
                             gpointer       user_data)
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
kc_text_area_get_property (GObject        *object,
                           guint           prop_id,
                           GValue         *value,
                           GParamSpec     *pspec)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    switch (prop_id) {
    case PROP_EDITABLE:
        g_value_set_boolean (value, self->editable);
        break;
    case PROP_TEXT:
        g_value_set_string (value, self->text);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_text_area_set_property (GObject        *object,
                           guint           prop_id,
                           const GValue   *value,
                           GParamSpec     *pspec)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    switch (prop_id) {
    case PROP_EDITABLE:
        self->editable = g_value_get_boolean (value);
        break;
    case PROP_TEXT:
        self->text = g_value_get_string (value);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_text_area_constructed (GObject *object)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    gtk_text_view_set_editable (GTK_TEXT_VIEW (self->source_view), self->editable);

    G_OBJECT_CLASS (kc_text_area_parent_class)->constructed (object);
}

static void
kc_text_area_dispose (GObject *object)
{
    KcTextArea *self = KC_TEXT_AREA (object);

    gtk_text_view_set_buffer (GTK_TEXT_VIEW (self->source_view), NULL);
    g_clear_object (&(self->buffer));

    adw_bin_set_child (ADW_BIN (self), NULL);

    G_OBJECT_CLASS (kc_text_area_parent_class)->dispose (object);
}

static void
kc_text_area_class_init (KcTextAreaClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->get_property = kc_text_area_get_property;
    object_class->set_property = kc_text_area_set_property;
    object_class->constructed = kc_text_area_constructed;
    object_class->dispose = kc_text_area_dispose;

    props[PROP_EDITABLE] =
        g_param_spec_boolean ("editable", NULL, NULL,
                              FALSE,
                              G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS);

    props[PROP_TEXT] =
        g_param_spec_string ("text", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);

    g_object_class_install_properties (object_class, N_PROPS, props);
}

static void
kc_text_area_init (KcTextArea *self)
{
    GtkSourceStyleSchemeManager *style_scheme_manager;
    GtkSettings *gtk_settings;
    GtkWidget *scrolled;

    self->editable = FALSE;
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
    g_object_bind_property (self->buffer, "text",
                            self, "text",
                            G_BINDING_BIDIRECTIONAL | G_BINDING_SYNC_CREATE);

    // Apply theme changes to the source view
    g_object_bind_property_full (gtk_settings, "gtk-application-prefer-dark-theme",
                                 self->buffer, "style-scheme",
                                 G_BINDING_SYNC_CREATE | G_BINDING_SYNC_CREATE,
                                 prefer_dark_to_style_scheme,
                                 NULL,
                                 style_scheme_manager,
                                 NULL);
}

const char *
kc_text_area_get_text (KcTextArea *self)
{
    g_return_val_if_fail (KC_IS_TEXT_AREA (self), NULL);

    return self->text;
}

void
kc_text_area_set_text (KcTextArea *self,
                       const char *text)
{
    g_return_if_fail (KC_IS_TEXT_AREA (self));

    if (g_strcmp0 (self->text, text) == 0) {
        return;
    }

    self->text = text;
}

void
kc_text_area_clear_text (KcTextArea *self)
{
    kc_text_area_set_text (self, "");
}

void
kc_text_area_grab_focus (KcTextArea *self)
{
    g_return_if_fail (KC_IS_TEXT_AREA (self));

    gtk_widget_grab_focus (GTK_WIDGET (self->source_view));
}

KcTextArea *
kc_text_area_new (gboolean editable)
{
    return g_object_new (KC_TYPE_TEXT_AREA,
                         "editable", editable,
                         NULL);
}
