/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned ComboEntry source_combo_entry;
    [GtkChild]
    private unowned ComboEntry result_combo_entry;
    [GtkChild]
    private unowned Granite.Toast toast;

    private ChCase.Converter converter;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        converter = new ChCase.Converter ();

        source_combo_entry.get_source_view ().grab_focus ();

        source_combo_entry.dropdown_changed.connect (() => {
            do_convert ();
        });
        result_combo_entry.dropdown_changed.connect (() => {
            do_convert ();
        });

        source_combo_entry.text_changed.connect (() => {
            do_convert ();
        });

        source_combo_entry.text_copied.connect (show_toast);
        result_combo_entry.text_copied.connect (show_toast);
    }

    private void show_toast () {
        toast.send_notification ();
    }

    private void do_convert () {
        set_case_type (source_combo_entry.case_type, result_combo_entry.case_type);
        result_combo_entry.text = convert_case (source_combo_entry.text);
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
