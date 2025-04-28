/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class SourcePane : BasePane {
    public SourcePane () {
        Object (
            header_label: _("Convert _From:"),
            editable: true
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum ("source-case-type");

        notify["case-type"].connect (() => {
            Application.settings.set_enum ("source-case-type", case_type);
        });

        Application.settings.bind ("source-text", this, "text", SettingsBindFlags.DEFAULT);
    }
}
