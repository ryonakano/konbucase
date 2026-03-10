/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Define {
    /**
     * String representation of Adw.ColorScheme.
     *
     * Note: Only defines necessary strings for the app.
     *
     * @see Util.Convert.to_str_scheme
     * @see Util.Convert.to_adw_scheme
     */
    namespace ColorScheme {
        /**
         * Inherit the parent color-scheme.
         *
         * @see Adw.ColorScheme.DEFAULT
         */
        public const string DEFAULT = "default";
        /**
         * Always use light appearance.
         *
         * @see Adw.ColorScheme.FORCE_LIGHT
         */
        public const string FORCE_LIGHT = "force-light";
        /**
         * Always use dark appearance.
         *
         * @see Adw.ColorScheme.FORCE_DARK
         */
        public const string FORCE_DARK = "force-dark";
    }

    /**
     * Type of letter cases in a piece of text.
     */
    // Note: Keep the same order with "case-type" enum definition in the gschema file
    public enum CaseType {
        /**
         * Use a space as a word separator, e.g. "foo bar baz".
         */
        SPACE_SEPARATED,
        /**
         * Camel Case, e.g. "fooBarBaz".
         */
        CAMEL,
        /**
         * Pascal Case, e.g. "FooBarBaz".
         */
        PASCAL,
        /**
         * Snake Case, e.g. "foo_bar_baz".
         */
        SNAKE,
        /**
         * Kebab Case, e.g. "foo-bar-baz".
         */
        KEBAB,
        /**
         * Sentence Case, e.g. "Foo bar baz".
         */
        SENTENCE,
    }
}
