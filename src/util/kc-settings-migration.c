/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-settings-migration.h"

/**
 * Handles backward compatibility of app preferences.
 */

/**
 * KcSettingsMigrationFunc:
 * @settings: (transfer none): the target #GSettings for migration. The preference should be saved to new key(s)
 *            using setters of #GSettings e.g. g_settings_set_value()
 * @old_val: (transfer none): an app preference that the old key has
 *
 * Migrates an app preference in an old key in @settings.
 *
 * Returns: `TRUE` if succeeds, `FALSE` otherwise
 */
typedef gboolean (*KcSettingsMigrationFunc) (GSettings *settings, GVariant *old_val);

/**
 * KcSettingsMigrationEntry:
 * Data structure to migrate an app preference saved in a key of #GSettings.
 */
typedef struct {
    /**
     * Key name before migration.
     */
    const gchar             *old_key;

    /**
     * Migration procedure.
     */
    KcSettingsMigrationFunc  migrate;
} KcSettingsMigrationEntry;

static gboolean
migrate_source_text (GSettings  *settings,
                     GVariant   *old_val)
{
    g_settings_set_value (settings, "input-text", old_val);

    return TRUE;
}

static gboolean
migrate_source_case_type (GSettings *settings,
                          GVariant  *old_val)
{
    g_settings_set_value (settings, "input-case-type", old_val);

    return TRUE;
}

static gboolean
migrate_result_case_type (GSettings *settings,
                          GVariant  *old_val)
{
    g_settings_set_value (settings, "output-case-type", old_val);

    return TRUE;
}

/**
 * Table of data structures used for migration.
 */
static const KcSettingsMigrationEntry settings_migration_table[] = {
    {
        .old_key = "source-text",
        .migrate = migrate_source_text,
    },
    {
        .old_key = "source-case-type",
        .migrate = migrate_source_case_type,
    },
    {
        .old_key = "result-case-type",
        .migrate = migrate_result_case_type,
    },
    { NULL }
};

/**
 * kc_util_migrate_settings:
 * @settings: the target #GSettings for migration
 * @migration_table: table of data structures used for migration
 *
 * Migrates app preferences of @settings from old (deprecated) keys to new ones.
 *
 * Returns: `TRUE` if succeeds, `FALSE` otherwise
 */
gboolean
kc_util_migrate_settings (GSettings *settings)
{
    g_autoptr(GSettingsSchema) ss = NULL;
    const KcSettingsMigrationEntry *entry;
    gboolean has_key;
    GVariant *old_val;
    GSettingsSchemaKey *ssk;
    GVariant *default_val;
    gboolean equals;
    gboolean ret;

    g_return_val_if_fail (G_IS_SETTINGS (settings), FALSE);

    g_object_get (G_OBJECT (settings),
                  "settings-schema", &ss,
                  NULL);

    for (entry = settings_migration_table; entry->old_key != NULL; entry++) {
        has_key = g_settings_schema_has_key (ss, entry->old_key);
        if (!has_key) {
            continue;
        }

        old_val = g_settings_get_value (settings, entry->old_key);

        ssk = g_settings_schema_get_key (ss, entry->old_key);
        default_val = g_settings_schema_key_get_default_value (ssk);

        equals = g_variant_equal (old_val, default_val);
        if (equals) {
            // No need to migrate
            continue;
        }

        ret = entry->migrate (settings, old_val);
        if (!ret) {
            g_warning ("Failed to migrate settings. key=\"%s\"", entry->old_key);
            return FALSE;
        }

        g_settings_reset (settings, entry->old_key);
    }

    return TRUE;
}
