/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

/**
 * KcCaseType:
 * @KC_CASE_TYPE_SPACE_SEPARATED: Use a space as a word separator, e.g. "foo bar baz".
 * @KC_CASE_TYPE_CAMEL: Camel Case, e.g. "fooBarBaz".
 * @KC_CASE_TYPE_PASCAL: Pascal Case, e.g. "FooBarBaz".
 * @KC_CASE_TYPE_SNAKE: Snake Case, e.g. "foo_bar_baz".
 * @KC_CASE_TYPE_KEBAB: Kebab Case, e.g. "foo-bar-baz".
 * @KC_CASE_TYPE_SENTENCE: Sentence Case, e.g. "Foo bar baz".
 *
 * Type of letter cases in a piece of text.
 */
// Note: Keep the same order with "case-type" enum definition in the gschema file
typedef enum {
    KC_CASE_TYPE_SPACE_SEPARATED,
    KC_CASE_TYPE_CAMEL,
    KC_CASE_TYPE_PASCAL,
    KC_CASE_TYPE_SNAKE,
    KC_CASE_TYPE_KEBAB,
    KC_CASE_TYPE_SENTENCE,
} KcCaseType;
