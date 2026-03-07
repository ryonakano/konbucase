/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A list model that has information about a letter case.
 */
public class Model.CaseListItemModel : Object {
    /**
     * Type of the letter case.
     */
    public Define.CaseType case_type { get; construct; }

    /**
     * Display name of the letter case.
     */
    public string name { get; construct; }

    /**
     * Description of the letter case.
     */
    public string description { get; construct; }

    /**
     * Creates a new {@link Model.CaseListItemModel}.
     *
     * @param case_type     type of the letter case
     * @param name          display name of the letter case
     * @param description   description of the letter case
     *
     * @return              a new {@link Model.CaseListItemModel}
     */
    public CaseListItemModel (Define.CaseType case_type, string name, string description) {
        Object (
            case_type: case_type,
            name: name,
            description: description
        );
    }
}
