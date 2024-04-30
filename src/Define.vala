/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Define {
    /**
     * String representation of Adw.ColorScheme.
     *
     * Note: Only defines necessary strings for the app.
     */
    namespace ColorScheme {
        /** Inherit the parent color-scheme. */
        public const string DEFAULT = "default";
        /** Always use light appearance. */
        public const string FORCE_LIGHT = "force-light";
        /** Always use dark appearance. */
        public const string FORCE_DARK = "force-dark";
    }

    /**
     * Type of the text.
     */
    public enum TextType {
        /** Text that is converted. */
        SOURCE,
        /** Text after conversion. */
        RESULT,
    }

    // Make sure to match with case-type enum in the gschema
    public enum CaseType {
        SPACE_SEPARATED = ChCase.Case.SPACE_SEPARATED,
        CAMEL = ChCase.Case.CAMEL,
        PASCAL = ChCase.Case.PASCAL,
        SNAKE = ChCase.Case.SNAKE,
        KEBAB = ChCase.Case.KEBAB,
        SENTENCE = ChCase.Case.SENTENCE,
    }
}
