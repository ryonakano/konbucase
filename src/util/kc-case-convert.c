/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-case-convert.h"

/**
 * KcCaseConvert:
 *
 * Converts data types related to case conversion and do case conversion itself.
 */

/**
 * kc_case_convert_to_case_type:
 * @chcase_case: a `ChCaseCase`
 *
 * Converts `ChCaseCase` to `KcCaseType`.
 *
 * Returns: a `KcCaseType`
 */
KcCaseType
kc_case_convert_to_case_type (ChCaseCase chcase_case)
{
    switch (chcase_case) {
    case CHCASE_CASE_SPACE_SEPARATED:
        return KC_CASE_TYPE_SPACE_SEPARATED;
    case CHCASE_CASE_CAMEL:
        return KC_CASE_TYPE_CAMEL;
    case CHCASE_CASE_PASCAL:
        return KC_CASE_TYPE_PASCAL;
    case CHCASE_CASE_SNAKE:
        return KC_CASE_TYPE_SNAKE;
    case CHCASE_CASE_KEBAB:
        return KC_CASE_TYPE_KEBAB;
    case CHCASE_CASE_SENTENCE:
        return KC_CASE_TYPE_SENTENCE;
    default:
        g_warning ("Invalid ChCase.Case: %u", chcase_case);
        return KC_CASE_TYPE_SPACE_SEPARATED;
    }
}

/**
 * kc_case_convert_to_chcase_case:
 * @case_type: a `KcCaseType`
 *
 * Converts `KcCaseType` to `ChCaseCase`.
 *
 * Returns: a `ChCaseCase`
 */
ChCaseCase
kc_case_convert_to_chcase_case (KcCaseType case_type)
{
    switch (case_type) {
    case KC_CASE_TYPE_SPACE_SEPARATED:
        return CHCASE_CASE_SPACE_SEPARATED;
    case KC_CASE_TYPE_CAMEL:
        return CHCASE_CASE_CAMEL;
    case KC_CASE_TYPE_PASCAL:
        return CHCASE_CASE_PASCAL;
    case KC_CASE_TYPE_SNAKE:
        return CHCASE_CASE_SNAKE;
    case KC_CASE_TYPE_KEBAB:
        return CHCASE_CASE_KEBAB;
    case KC_CASE_TYPE_SENTENCE:
        return CHCASE_CASE_SENTENCE;
    default:
        g_warning ("Invalid KcCaseType: %u", case_type);
        return CHCASE_CASE_SPACE_SEPARATED;
    }
}

/**
 * kc_case_convert_do_convert:
 * @converter: (transfer none): a case converter
 * @input_case: case type of input text
 * @input_text: (transfer none): text that is converted
 * @output_case: case type of output text
 *
 * Converts case of a piece of text.
 *
 * Returns: (transfer full): text after conversion
 */
char *
kc_case_convert_do_convert (ChCaseConverter *converter,
                            KcCaseType       input_case,
                            const char      *input_text,
                            KcCaseType       output_case)
{
    char *output_text;

    g_return_val_if_fail (CHCASE_IS_CONVERTER (converter), NULL);
    g_return_val_if_fail (input_text != NULL, NULL);

    chcase_converter_set_input_case (converter, kc_case_convert_to_chcase_case (input_case));
    chcase_converter_set_output_case (converter, kc_case_convert_to_chcase_case (output_case));

    output_text = chcase_converter_convert_case (converter, input_text);

    return output_text;
}
