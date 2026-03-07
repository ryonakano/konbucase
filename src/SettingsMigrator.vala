/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A class that handles backward compatibility of app preferences.
 */
public class SettingsMigrator : Object {
    /**
     * The target {@link GLib.Settings} for migration.
     */
    public unowned Settings settings { get; construct; }

    /**
     * Migrate app preference of a old key before migration in ``settings``.
     *
     * @param settings  the target {@link GLib.Settings} for migration. User preference should be saved to a new key
     *                  using a setter of {@link GLib.Settings} e.g. {@link GLib.Settings.set_value}
     * @param old_val   app preference that the old key has
     *
     * @return          ``true`` if succeeds, ``false`` otherwise
     */
    [CCode (has_target = false)]
    private delegate bool SettingsMigrationFunc (Settings settings, Variant old_val);

    /**
     * Data structure to migrate app preferences saved in a key of {@link GLib.Settings}.
     */
    private struct SettingsMigrationEntry {
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
     * Table of data structures used for migration.
     */
    private static SettingsMigrationEntry[] settings_migration_table = {
        {
            "source-text",
            ((settings, old_val) => {
                settings.set_value ("input-text", old_val);
                return true;
            }),
        },
        {
            "source-case-type",
            ((settings, old_val) => {
                settings.set_value ("input-case-type", old_val);
                return true;
            }),
        },
        {
            "result-case-type",
            ((settings, old_val) => {
                settings.set_value ("output-case-type", old_val);
                return true;
            }),
        },
    };

    /**
     * Creates a new {@link SettingsMigrator}.
     *
     * @param settings      the target {@link GLib.Settings} for migration
     *
     * @return              a new {@link SettingsMigrator}
     */
    public SettingsMigrator (Settings settings) {
        Object (
            settings: settings
        );
    }

    /**
     * Migrates app preferences of {@link settings} from old (deprecated) keys to new ones.
     *
     * @return              ``true`` if succeeds, ``false`` otherwise
     */
    public bool migrate () {
        SettingsSchema ss = settings.settings_schema;

        foreach (unowned var entry in settings_migration_table) {
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
