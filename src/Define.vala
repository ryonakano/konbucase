/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Define {
    /**
     * Constants for the "style" enum in the gschema.
     */
    namespace Style {
        /** Inherit the system style. */
        public const string DEFAULT = "default";
        /** Always use light appearance. */
        public const string LIGHT = "light";
        /** Always use dark appearance. */
        public const string DARK = "dark";
    }

    // Make sure to match with source-type enum in the gschema
    public enum CaseType {
        SPACE_SEPARATED = ChCase.Case.SPACE_SEPARATED,
        CAMEL = ChCase.Case.CAMEL,
        PASCAL = ChCase.Case.PASCAL,
        SNAKE = ChCase.Case.SNAKE,
        KEBAB = ChCase.Case.KEBAB,
        SENTENCE = ChCase.Case.SENTENCE,
    }
}
