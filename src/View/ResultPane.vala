/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class ResultPane : BasePane {
    public ResultPane () {
        Object (
            header_label: _("Convert _To:"),
            // Make the text view uneditable, otherwise the app freezes
            editable: false,
            text_type: Define.TextType.RESULT,
            key_case_type: "result-case-type",
            key_text: "result-text"
        );
    }
}
