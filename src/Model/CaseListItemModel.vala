/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class CaseListItemModel : Object {
    public Define.CaseType case_type { get; construct; }
    public string name { get; construct; }
    public string description { get; construct; }

    public CaseListItemModel (Define.CaseType case_type, string name, string description) {
        Object (
            case_type: case_type,
            name: name,
            description: description
        );
    }
}
