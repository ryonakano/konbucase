/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class ResultPane : BasePane {
    public ResultPane () {
        Object (
            header_label: _("Convert _To:"),
            // Make the text view uneditable, otherwise the app freezes
            editable: false
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum ("result-case-type");

        notify["case-type"].connect (() => {
            Application.settings.set_enum ("result-case-type", case_type);
        });

        Application.settings.bind ("result-text", this, "text", SettingsBindFlags.DEFAULT);
    }
}
