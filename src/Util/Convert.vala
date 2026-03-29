/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * Converts data types.
 */
namespace Util.Convert {
    /**
     * Converts {@link ChCase.Case} to {@link Define.CaseType}.
     *
     * @param chcase_case   a {@link ChCase.Case}
     *
     * @return              a {@link Define.CaseType}
     */
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

    /**
     * Converts {@link Define.CaseType} to {@link ChCase.Case}.
     *
     * @param case_type     a {@link Define.CaseType}
     *
     * @return              a {@link ChCase.Case}
     */
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

    /**
     * Converts string representation of a color scheme to {@link Adw.ColorScheme}.
     *
     * @param str_scheme    string representation of a color scheme
     *
     * @return              a {@link Adw.ColorScheme}
     */
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

    /**
     * Converts {@link Adw.ColorScheme} to string representation of a color scheme.
     *
     * @param adw_scheme    a {@link Adw.ColorScheme}
     *
     * @return              string representation of a color scheme
     */
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
}
