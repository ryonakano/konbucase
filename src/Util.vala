/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util {
    public static Define.CaseType to_case_type (ChCase.Case chcase_case) {
        switch (chcase_case) {
            case ChCase.Case.SPACE_SEPARATED:
            case ChCase.Case.CAMEL:
            case ChCase.Case.PASCAL:
            case ChCase.Case.SNAKE:
            case ChCase.Case.KEBAB:
            case ChCase.Case.SENTENCE:
                return (Define.CaseType) chcase_case;
            default:
                warning ("Invalid ChCase.Case: %d", chcase_case);
                return Define.CaseType.SPACE_SEPARATED;
        }
    }

    public static ChCase.Case to_chcase_case (Define.CaseType case_type) {
        switch (case_type) {
            case Define.CaseType.SPACE_SEPARATED:
            case Define.CaseType.CAMEL:
            case Define.CaseType.PASCAL:
            case Define.CaseType.SNAKE:
            case Define.CaseType.KEBAB:
            case Define.CaseType.SENTENCE:
                return (ChCase.Case) case_type;
            default:
                warning ("Invalid Define.CaseType: %d", case_type);
                return ChCase.Case.SPACE_SEPARATED;
        }
    }

    public static bool style_action_transform_to_cb (Binding binding, Value from_value, ref Value to_value) {
        Variant? variant = from_value.dup_variant ();
        if (variant == null) {
            warning ("Failed to Variant.dup_variant");
            return false;
        }

        var val = variant.get_string ();
        switch (val) {
            case StyleManager.COLOR_SCHEME_DEFAULT:
            case StyleManager.COLOR_SCHEME_FORCE_LIGHT:
            case StyleManager.COLOR_SCHEME_FORCE_DARK:
                to_value.set_string (val);
                break;
            default:
                warning ("style_action_transform_to_cb: Invalid color scheme: %s", val);
                return false;
        }

        return true;
    }

    public static bool style_action_transform_from_cb (Binding binding, Value from_value, ref Value to_value) {
        var val = (string) from_value;
        switch (val) {
            case StyleManager.COLOR_SCHEME_DEFAULT:
            case StyleManager.COLOR_SCHEME_FORCE_LIGHT:
            case StyleManager.COLOR_SCHEME_FORCE_DARK:
                to_value.set_variant (new Variant.string (val));
                break;
            default:
                warning ("style_action_transform_from_cb: Invalid color scheme: %s", val);
                return false;
        }

        return true;
    }

}
