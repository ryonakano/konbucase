/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class SourcePane : BasePane {
    public SourcePane () {
        Object (
            header_label: _("Convert _From:"),
            editable: true,
            text_type: Define.TextType.SOURCE,
            key_case_type: "source-case-type",
            key_text: "source-text"
        );
    }
}
