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

    /**
     * Set case type of source and result texts.
     *
     * @param source_case case type of source text
     * @param result_case case type of result text
     */
    public void set_case_type (Define.CaseType source_case, Define.CaseType result_case) {
        converter.source_case = Util.to_chcase_case (source_case);
        converter.result_case = Util.to_chcase_case (result_case);
    }

    /**
     * Convert case of source_text to the case set with {@link set_case_type}.
     *
     * @param source_text text that is converted
     * @return text after conversion
     */
    public string convert_case (string source_text) {
        return converter.convert_case (source_text);
    }
}
