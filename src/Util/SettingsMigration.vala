/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * Handles backward compatibility of app preferences.
 */
namespace Util.SettingsMigration {
    /**
     * Migrates an app preference in an old key in ``settings``.
     *
     * @param settings  the target {@link GLib.Settings} for migration. The preference should be saved to new key(s)
     *                  using setters of {@link GLib.Settings} e.g. {@link GLib.Settings.set_value}
     * @param old_val   an app preference that the old key has
     *
     * @return          ``true`` if succeeds, ``false`` otherwise
     */
    [CCode (has_target = false)]
    public delegate bool SettingsMigrationFunc (Settings settings, Variant old_val);

    /**
     * Data structure to migrate an app preference saved in a key of {@link GLib.Settings}.
     */
    public struct SettingsMigrationEntry {
        /**
         * Key name before migration.
         */
        string old_key;

        /**
         * Migration procedure.
         */
        unowned SettingsMigrationFunc migrate;
    }

    /**
     * Migrates app preferences of ``settings`` from old (deprecated) keys to new ones.
     *
     * @param settings          the target {@link GLib.Settings} for migration
     * @param migration_table   table of data structures used for migration
     *
     * @return                  ``true`` if succeeds, ``false`` otherwise
     */
    public static bool migrate (Settings settings, SettingsMigrationEntry[] migration_table) {
        SettingsSchema ss = settings.settings_schema;

        foreach (unowned var entry in migration_table) {
            if (!ss.has_key (entry.old_key)) {
                continue;
            }

            var old_val = settings.get_value (entry.old_key);

            SettingsSchemaKey ssk = ss.get_key (entry.old_key);
            var default_val = ssk.get_default_value ();
            if (old_val.equal (default_val)) {
                // No need to migrate
                continue;
            }

            bool ret = entry.migrate (settings, old_val);
            if (!ret) {
                warning ("Failed to migrate settings. key=\"%s\"", entry.old_key);
                return false;
            }

            settings.reset (entry.old_key);
        }

        return true;
    }
}
