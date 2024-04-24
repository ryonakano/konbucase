/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindowModel : Object {
    private ChCase.Converter converter;

    public MainWindowModel () {
    }

    construct {
        converter = new ChCase.Converter ();
    }

    public void set_case_type (Define.CaseType source_case, Define.CaseType result_case) {
        converter.source_case = Util.to_chcase_case (source_case);
        converter.result_case = Util.to_chcase_case (result_case);
    }

    public string convert_case (string source_text) {
        return converter.convert_case (source_text);
    }
}
