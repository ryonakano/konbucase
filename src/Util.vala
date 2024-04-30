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

    /**
     * Convert ``from_value`` to ``to_value``.
     *
     * @param binding       a binding
     * @param from_value    the value of Action.state property
     * @param to_value      the value of Adw.StyleManager.color_scheme property
     *
     * @return true if the transformation was successful, false otherwise
     * @see GLib.BindingTransformFunc
     */
    public static bool style_action_transform_to_cb (Binding binding, Value from_value, ref Value to_value) {
        Variant? variant = from_value.dup_variant ();
        if (variant == null) {
            warning ("Failed to Variant.dup_variant");
            return false;
        }

        var val = variant.get_string ();
        switch (val) {
            case Define.ColorScheme.DEFAULT:
                to_value.set_enum (Adw.ColorScheme.DEFAULT);
                break;
            case Define.ColorScheme.FORCE_LIGHT:
                to_value.set_enum (Adw.ColorScheme.FORCE_LIGHT);
                break;
            case Define.ColorScheme.FORCE_DARK:
                to_value.set_enum (Adw.ColorScheme.FORCE_DARK);
                break;
            default:
                warning ("style_action_transform_to_cb: Invalid color scheme: %s", val);
                return false;
        }

        return true;
    }

    /**
     * Convert ``from_value`` to ``to_value``.
     *
     * @param binding       a binding
     * @param from_value    the value of Adw.StyleManager.color_scheme property
     * @param to_value      the value of Action.state property
     *
     * @return true if the transformation was successful, false otherwise
     * @see GLib.BindingTransformFunc
     */
    public static bool style_action_transform_from_cb (Binding binding, Value from_value, ref Value to_value) {
        var val = (Adw.ColorScheme) from_value;
        switch (val) {
            case Adw.ColorScheme.DEFAULT:
                to_value.set_variant (new Variant.string (Define.ColorScheme.DEFAULT));
                break;
            case Adw.ColorScheme.FORCE_LIGHT:
                to_value.set_variant (new Variant.string (Define.ColorScheme.FORCE_LIGHT));
                break;
            case Adw.ColorScheme.FORCE_DARK:
                to_value.set_variant (new Variant.string (Define.ColorScheme.FORCE_DARK));
                break;
            default:
                warning ("style_action_transform_from_cb: Invalid color scheme: %d", val);
                return false;
        }

        return true;
    }

    /**
     * Convert from the "style" enum defined in the gschema to Adw.ColorScheme.
     *
     * @param value         the Value containing Adw.ColorScheme value
     * @param variant       the Variant containing "style" enum value defined in the gschema
     * @param user_data     unused (null)
     *
     * @return true if the conversion succeeded, false otherwise
     * @see GLib.SettingsBindGetMappingShared
     */
    public static bool color_scheme_get_mapping_cb (Value value, Variant variant, void* user_data) {
        var val = variant.get_string ();
        switch (val) {
            case Define.ColorScheme.DEFAULT:
                value.set_enum (Adw.ColorScheme.DEFAULT);
                break;
            case Define.ColorScheme.FORCE_LIGHT:
                value.set_enum (Adw.ColorScheme.FORCE_LIGHT);
                break;
            case Define.ColorScheme.FORCE_DARK:
                value.set_enum (Adw.ColorScheme.FORCE_DARK);
                break;
            default:
                warning ("color_scheme_get_mapping_cb: Invalid style: %s", val);
                return false;
        }

        return true;
    }

    /**
     * Convert from Adw.ColorScheme to the "style" enum defined in the gschema.
     *
     * @param value             the Value containing Adw.ColorScheme value
     * @param expected_type     the expected type of Variant that this method returns
     * @param user_data         unused (null)
     *
     * @return a new Variant containing "style" enum value defined in the gschema
     * @see GLib.SettingsBindSetMappingShared
     */
    public static Variant color_scheme_set_mapping_cb (Value value, VariantType expected_type, void* user_data) {
        string color_scheme;

        var val = (Adw.ColorScheme) value;
        switch (val) {
            case Adw.ColorScheme.DEFAULT:
                color_scheme = Define.ColorScheme.DEFAULT;
                break;
            case Adw.ColorScheme.FORCE_LIGHT:
                color_scheme = Define.ColorScheme.FORCE_LIGHT;
                break;
            case Adw.ColorScheme.FORCE_DARK:
                color_scheme = Define.ColorScheme.FORCE_DARK;
                break;
            default:
                warning ("color_scheme_set_mapping_cb: Invalid Adw.ColorScheme: %d", val);
                // fallback to default
                color_scheme = Define.ColorScheme.DEFAULT;
                break;
        }

        return new Variant.string (color_scheme);
    }
}
