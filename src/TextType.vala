/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public enum TextType {
    SOURCE,
    RESULT;

    public string get_case_label () {
        switch (this) {
            case TextType.SOURCE:
                return _("Convert from:");
            case TextType.RESULT:
                return _("Convert to:");
            default:
                assert_not_reached ();
        }
    }

    public string get_identifier () {
        switch (this) {
            case TextType.SOURCE:
                return "source";
            case TextType.RESULT:
                return "result";
            default:
                assert_not_reached ();
        }
    }
}
