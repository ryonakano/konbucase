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
}
