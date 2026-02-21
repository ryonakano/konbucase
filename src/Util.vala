/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util {
    /**
     * Data structure to migrate user preferences saved in {@Settings}.
     */
    public struct SettingsMigrateEntry {
        /**
         * Key name before migration.
         */
        string old_key;

        /**
         * Key name after migration.
         */
        string new_key;
    }

    /**
     * Whether the app is running on Pantheon desktop environment.
     */
    public static bool is_on_pantheon () {
        return Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
    }

    public static Define.CaseType to_case_type (ChCase.Case chcase_case) {
        switch (chcase_case) {
            case ChCase.Case.SPACE_SEPARATED:
                return Define.CaseType.SPACE_SEPARATED;
            case ChCase.Case.CAMEL:
                return Define.CaseType.CAMEL;
            case ChCase.Case.PASCAL:
                return Define.CaseType.PASCAL;
            case ChCase.Case.SNAKE:
                return Define.CaseType.SNAKE;
            case ChCase.Case.KEBAB:
                return Define.CaseType.KEBAB;
            case ChCase.Case.SENTENCE:
                return Define.CaseType.SENTENCE;
            default:
                warning ("Invalid ChCase.Case: %d", chcase_case);
                return Define.CaseType.SPACE_SEPARATED;
        }
    }

    public static ChCase.Case to_chcase_case (Define.CaseType case_type) {
        switch (case_type) {
            case Define.CaseType.SPACE_SEPARATED:
                return ChCase.Case.SPACE_SEPARATED;
            case Define.CaseType.CAMEL:
                return ChCase.Case.CAMEL;
            case Define.CaseType.PASCAL:
                return ChCase.Case.PASCAL;
            case Define.CaseType.SNAKE:
                return ChCase.Case.SNAKE;
            case Define.CaseType.KEBAB:
                return ChCase.Case.KEBAB;
            case Define.CaseType.SENTENCE:
                return ChCase.Case.SENTENCE;
            default:
                warning ("Invalid Define.CaseType: %d", case_type);
                return ChCase.Case.SPACE_SEPARATED;
        }
    }

    public static Adw.ColorScheme to_adw_scheme (string str_scheme) {
        switch (str_scheme) {
            case Define.ColorScheme.DEFAULT:
                return Adw.ColorScheme.DEFAULT;
            case Define.ColorScheme.FORCE_LIGHT:
                return Adw.ColorScheme.FORCE_LIGHT;
            case Define.ColorScheme.FORCE_DARK:
                return Adw.ColorScheme.FORCE_DARK;
            default:
                warning ("Invalid color scheme string: %s", str_scheme);
                return Adw.ColorScheme.DEFAULT;
        }
    }

    public static string to_str_scheme (Adw.ColorScheme adw_scheme) {
        switch (adw_scheme) {
            case Adw.ColorScheme.DEFAULT:
                return Define.ColorScheme.DEFAULT;
            case Adw.ColorScheme.FORCE_LIGHT:
                return Define.ColorScheme.FORCE_LIGHT;
            case Adw.ColorScheme.FORCE_DARK:
                return Define.ColorScheme.FORCE_DARK;
            default:
                warning ("Invalid color scheme: %d", adw_scheme);
                return Define.ColorScheme.DEFAULT;
        }
    }

    public static void migrate_settings (Settings settings, SettingsMigrateEntry[] table) {
        SettingsSchema ss = settings.settings_schema;

        foreach (unowned var entry in table) {
            if (!ss.has_key (entry.old_key)) {
                continue;
            }

            var val = settings.get_value (entry.old_key);

            SettingsSchemaKey ssk = ss.get_key (entry.old_key);
            var default_val = ssk.get_default_value ();
            if (val.equal (default_val)) {
                // No need to migrate
                continue;
            }

            settings.set_value (entry.new_key, val);

            settings.reset (entry.old_key);
        }
    }
}
