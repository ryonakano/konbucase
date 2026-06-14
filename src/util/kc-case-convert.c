/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-case-convert.h"

KcCaseType
kc_case_convert_to_case_type (ChCaseCase chcase_case)
{
    switch (chcase_case) {
    case CH_CASE_CASE_SPACE_SEPARATED:
        return KC_CASE_TYPE_SPACE_SEPARATED;
    case CH_CASE_CASE_CAMEL:
        return KC_CASE_TYPE_CAMEL;
    case CH_CASE_CASE_PASCAL:
        return KC_CASE_TYPE_PASCAL;
    case CH_CASE_CASE_SNAKE:
        return KC_CASE_TYPE_SNAKE;
    case CH_CASE_CASE_KEBAB:
        return KC_CASE_TYPE_KEBAB;
    case CH_CASE_CASE_SENTENCE:
        return KC_CASE_TYPE_SENTENCE;
    default:
        g_warning ("Invalid ChCase.Case: %d", chcase_case);
        return KC_CASE_TYPE_SPACE_SEPARATED;
    }
}

ChCaseCase
kc_case_convert_to_chcase_case (KcCaseType case_type)
{
    switch (case_type) {
    case KC_CASE_TYPE_SPACE_SEPARATED:
        return CH_CASE_CASE_SPACE_SEPARATED;
    case KC_CASE_TYPE_CAMEL:
        return CH_CASE_CASE_CAMEL;
    case KC_CASE_TYPE_PASCAL:
        return CH_CASE_CASE_PASCAL;
    case KC_CASE_TYPE_SNAKE:
        return CH_CASE_CASE_SNAKE;
    case KC_CASE_TYPE_KEBAB:
        return CH_CASE_CASE_KEBAB;
    case KC_CASE_TYPE_SENTENCE:
        return CH_CASE_CASE_SENTENCE;
    default:
        g_warning ("Invalid KcCaseType: %d", case_type);
        return CH_CASE_CASE_SPACE_SEPARATED;
    }
}

char *
kc_case_convert_do_convert (ChCaseConverter    *converter,
                            KcCaseType          input_case,
                            const char         *input_text,
                            KcCaseType          output_case)
{
    char *output_text;

    g_return_val_if_fail (CH_CASE_IS_CONVERTER (converter), NULL);
    g_return_val_if_fail (input_text != NULL, NULL);

    ch_case_converter_set_input_case (converter, kc_case_convert_to_chcase_case (input_case));
    ch_case_converter_set_output_case (converter, kc_case_convert_to_chcase_case (output_case));

    output_text = ch_case_converter_convert_case (converter, input_text);

    return output_text;
}

