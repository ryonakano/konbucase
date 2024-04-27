/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindowModel : Object {
    public ComboEntryModel source_model { get; construct; }
    public ComboEntryModel result_model { get; construct; }

    private ChCase.Converter converter;

    public MainWindowModel (ComboEntryModel source_model, ComboEntryModel result_model) {
        Object (
            source_model: source_model,
            result_model: result_model
        );
    }

    construct {
        converter = new ChCase.Converter ();
    }

    public void do_convert () {
        set_case_type (source_model.case_type, result_model.case_type);
        result_model.text = convert_case (source_model.text);
    }

    /**
     * Set case type of source and result texts.
     *
     * @param source_case case type of source text
     * @param result_case case type of result text
     */
    private void set_case_type (Define.CaseType source_case, Define.CaseType result_case) {
        converter.source_case = Util.to_chcase_case (source_case);
        converter.result_case = Util.to_chcase_case (result_case);
    }

    /**
     * Convert case of source_text to the case set with {@link set_case_type}.
     *
     * @param source_text text that is converted
     * @return text after conversion
     */
    private string convert_case (string source_text) {
        return converter.convert_case (source_text);
    }
}
