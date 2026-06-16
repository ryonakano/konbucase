/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "config.h"

#include "kc-application.h"

#include <adwaita.h>
#ifdef USE_GRANITE
#include <granite-7/granite-7.h>
#endif /* USE_GRANITE */
#include <glib/gi18n.h>

#include "kc-common.h"
#include "kc-convert.h"
#include "kc-main-window.h"
#include "kc-settings-migration.h"
#include "kc-util.h"

struct _KcApplication {
    AdwApplication       parent_instance;

    KcMainWindow        *window;
    GSettings           *settings;
};

G_DEFINE_FINAL_TYPE (KcApplication, kc_application, ADW_TYPE_APPLICATION)

static void
on_about_activate (GSimpleAction         *action,
                   GVariant              *parameter,
                   gpointer               user_data)
{
    KcApplication *self = KC_APPLICATION (user_data);
    AdwDialog *about_dialog;
    // List of maintainers
    const char *developers[] = {
        "Ryo Nakano <ryonakaknock3@gmail.com>",
        NULL
    };
    // List of icon authors
    const char *artists[] = {
        "Ryo Nakano <ryonakaknock3@gmail.com>",
        "Nararyans R.I. https://github.com/Fatih20",
        "Leo https://github.com/lenemter",
        NULL
    };

    (void) action;
    (void) parameter;

    about_dialog = adw_about_dialog_new_from_appdata (RESOURCE_PREFIX "/" APP_ID ".metainfo.xml", NULL);
    adw_about_dialog_set_version (ADW_ABOUT_DIALOG (about_dialog), APP_VERSION);
    adw_about_dialog_set_copyright (ADW_ABOUT_DIALOG (about_dialog), "© 2020-2026 Ryo Nakano");
    adw_about_dialog_set_developers (ADW_ABOUT_DIALOG (about_dialog), developers);
    adw_about_dialog_set_artists (ADW_ABOUT_DIALOG (about_dialog), artists);
    ///TRANSLATORS: A newline-separated list of translators. Don't translate literally.
    ///You can optionally add your name if you want, plus you may add your email address or website.
    ///e.g.:
    ///John Doe
    ///John Doe <john-doe@example.com>
    ///John Doe https://example.com
    adw_about_dialog_set_translator_credits (ADW_ABOUT_DIALOG (about_dialog), _("translator-credits"));
    adw_dialog_present (about_dialog, GTK_WIDGET (self->window));
}

static void
on_quit_activate (GSimpleAction         *action,
                  GVariant              *parameter,
                  gpointer               user_data)
{
    KcApplication *self = KC_APPLICATION (user_data);

    (void) action;
    (void) parameter;

    if (self->window) {
        gtk_window_destroy (GTK_WINDOW (self->window));
    }
}

static const GActionEntry action_entries[] = {
    {
        .name       = "about",
        .activate   = on_about_activate,
    },
    {
        .name       = "quit",
        .activate   = on_quit_activate,
    },
};

static void
kc_application_activate (GApplication *application)
{
    KcApplication *self = KC_APPLICATION (application);

    if (self->window) {
        gtk_window_present (GTK_WINDOW (self->window));
        return;
    }

    self->window = kc_main_window_new ();
    g_settings_bind (self->settings, "window-height", self->window, "default-height", G_SETTINGS_BIND_DEFAULT);
    g_settings_bind (self->settings, "window-width", self->window, "default-width", G_SETTINGS_BIND_DEFAULT);
    g_settings_bind (self->settings, "window-maximized", self->window, "maximized", G_SETTINGS_BIND_DEFAULT);
    gtk_window_set_application (GTK_WINDOW (self->window), GTK_APPLICATION (application));
    gtk_window_present (GTK_WINDOW (self->window));
}

static gboolean
gaction_state_to_adw_scheme (GBinding      *binding,
                             const GValue  *gaction_state,
                             GValue        *adw_scheme,
                             gpointer       user_data)
{
    g_autoptr(GVariant) gaction_state_variant = NULL;
    const gchar *gaction_state_str;
    AdwColorScheme adw_scheme_enum;

    (void) binding;
    (void) user_data;

    gaction_state_variant = g_value_dup_variant (gaction_state);
    if (!gaction_state_variant) {
        g_warning ("Failed to g_value_dup_variant()");
        return FALSE;
    }

    gaction_state_str = g_variant_get_string (gaction_state_variant, NULL);
    adw_scheme_enum = kc_convert_to_adw_scheme (gaction_state_str);
    g_value_set_enum (adw_scheme, adw_scheme_enum);

    return TRUE;
}

static gboolean
adw_scheme_to_gaction_state (GBinding      *binding,
                             const GValue  *adw_scheme,
                             GValue        *gaction_state,
                             gpointer       user_data)
{
    AdwColorScheme adw_scheme_enum;
    const gchar *gaction_state_str;

    (void) binding;
    (void) user_data;

    adw_scheme_enum = g_value_get_enum (adw_scheme);
    gaction_state_str = kc_convert_to_str_scheme (adw_scheme_enum);
    g_value_set_variant (gaction_state, g_variant_new_string (gaction_state_str));

    return TRUE;
}

static gboolean
settings_color_scheme_get_mapping (GValue   *adw_scheme,
                                   GVariant *gschema_scheme,
                                   gpointer  user_data)
{
    const gchar *gschema_scheme_str;
    AdwColorScheme adw_scheme_enum;

    (void) user_data;

    gschema_scheme_str = g_variant_get_string (gschema_scheme, NULL);
    adw_scheme_enum = kc_convert_to_adw_scheme (gschema_scheme_str);
    g_value_set_enum (adw_scheme, adw_scheme_enum);

    return TRUE;
}

static GVariant *
settings_color_scheme_set_mapping (const GValue         *adw_scheme,
                                   const GVariantType   *expected_type,
                                   gpointer              user_data)
{
    AdwColorScheme adw_scheme_enum;
    const gchar *gschema_scheme_str;
    GVariant *gschema_scheme_variant;

    (void) expected_type;
    (void) user_data;

    adw_scheme_enum = g_value_get_enum (adw_scheme);
    gschema_scheme_str = kc_convert_to_str_scheme (adw_scheme_enum);
    gschema_scheme_variant = g_variant_new_string (gschema_scheme_str);

    return gschema_scheme_variant;
}

/*
 * Inspired from Rnote:
 * https://github.com/flxzt/rnote/blob/v0.9.4/crates/rnote-ui/src/app/appactions.rs#L11-L36
 * https://github.com/flxzt/rnote/blob/v0.9.4/crates/rnote-ui/src/appwindow/appsettings.rs#L14-L28
 */
static void
setup_style (KcApplication *self)
{
    AdwStyleManager *style_manager;
    g_autoptr(GSimpleAction) style_action = NULL;

    style_manager = adw_application_get_style_manager (ADW_APPLICATION (self));

    style_action = g_simple_action_new_stateful ("color-scheme",
                                                 G_VARIANT_TYPE_STRING,
                                                 g_variant_new_string (KC_COLOR_SCHEME_DEFAULT));

    g_object_bind_property_full (G_OBJECT (style_action), "state",
                                 G_OBJECT (style_manager), "color-scheme",
                                 G_BINDING_BIDIRECTIONAL | G_BINDING_SYNC_CREATE,
                                 gaction_state_to_adw_scheme,
                                 adw_scheme_to_gaction_state,
                                 NULL,
                                 NULL);

    g_settings_bind_with_mapping (self->settings, "color-scheme",
                                  G_OBJECT (style_manager), "color-scheme",
                                  G_SETTINGS_BIND_DEFAULT,
                                  settings_color_scheme_get_mapping,
                                  settings_color_scheme_set_mapping,
                                  NULL,
                                  NULL);

    g_action_map_add_action (G_ACTION_MAP (self), G_ACTION (style_action));
}

static void
kc_application_startup (GApplication *application)
{
    KcApplication *self = KC_APPLICATION (application);

#ifdef USE_GRANITE
        // Use both compile-time and runtime conditions to:
        //
        //  * make Granite optional dependency
        //  * make sure to respect currently running DE
        if (kc_util_is_pantheon ()) {
            // Apply elementary stylesheet instead of default Adwaita stylesheet
            granite_init ();
        }
#endif /* USE_GRANITE */

    G_APPLICATION_CLASS (kc_application_parent_class)->startup (application);

    setup_style (self);

    // Migrate app preferences from old versions
    // Ignore return value because failure just results old app preferences not migrated
    kc_util_migrate_settings (self->settings);
}

static void
kc_application_dispose (GObject *object)
{
    KcApplication *self = KC_APPLICATION (object);

    // self->window should be already freed

    g_clear_object (&(self->settings));

    G_OBJECT_CLASS (kc_application_parent_class)->dispose (object);
}

static void
kc_application_class_init (KcApplicationClass *klass)
{
    GApplicationClass *application_class = G_APPLICATION_CLASS (klass);
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    application_class->activate = kc_application_activate;
    application_class->startup = kc_application_startup;

    object_class->dispose = kc_application_dispose;
}

static void
kc_application_init (KcApplication *self)
{
    const char * const app_quit_accels[] = {
        "<Control>q",
        NULL
    };

    self->settings = g_settings_new (APP_ID);
    self->window = NULL;

    g_action_map_add_action_entries (G_ACTION_MAP (self), action_entries, G_N_ELEMENTS (action_entries), self);
    gtk_application_set_accels_for_action (GTK_APPLICATION (self), "app.quit", app_quit_accels);
}

KcApplication *
kc_application_new (void)
{
    return g_object_new (KC_TYPE_APPLICATION,
                         "application-id", APP_ID,
                         "flags", G_APPLICATION_DEFAULT_FLAGS,
                         "resource-base-path", RESOURCE_PREFIX,
                         NULL);
}
