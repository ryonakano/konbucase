/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Widget.MainContent : Adw.Bin {
    private Adw.ToastOverlay overlay;

    private ChCase.Converter converter;

    public MainContent () {
    }

    construct {
        /*************************************************/
        /* Source Pane                                   */
        /*************************************************/
        var clear_button = new Gtk.Button.from_icon_name ("edit-clear") {
            tooltip_text = _("Clear")
        };

        var source_toolbar = new Widget.Toolbar (_("Convert _From:")) {
            valign = Gtk.Align.START,
            case_type = (Define.CaseType) Application.settings.get_enum ("source-case-type")
        };
        source_toolbar.append (clear_button);

        var source_textarea = new Widget.TextArea (true);

        /*************************************************/
        /* Separator                                     */
        /*************************************************/
        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        /*************************************************/
        /* Result Pane                                   */
        /*************************************************/
        var result_toolbar = new Widget.Toolbar (_("Convert _To:")) {
            valign = Gtk.Align.START,
            case_type = (Define.CaseType) Application.settings.get_enum ("result-case-type")
        };
        // Make the text view uneditable, otherwise the app freezes
        var result_textarea = new Widget.TextArea (false);

        var content_grid = new Gtk.Grid () {
            column_homogeneous = false
        };
        content_grid.attach (source_toolbar, 0, 0);
        content_grid.attach (source_textarea, 0, 1);
        content_grid.attach (separator, 1, 0, 1, 2);
        content_grid.attach (result_toolbar, 2, 0);
        content_grid.attach (result_textarea, 2, 1);

        overlay = new Adw.ToastOverlay () {
            child = content_grid
        };

        child = overlay;

        converter = new ChCase.Converter ();

        // The action users most frequently take is to input the source text.
        // So, forcus to the source view by default.
        source_textarea.grab_focus ();

        // Make copy button only sensitive when there are texts to copy
        source_textarea.bind_property (
            "text",
            source_toolbar.copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, text, ref sensitive) => {
                sensitive = ((string) text).length > 0;
                return true;
            }
        );
        result_textarea.bind_property (
            "text",
            result_toolbar.copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, text, ref sensitive) => {
                sensitive = ((string) text).length > 0;
                return true;
            }
        );

        // Make clear button only sensitive when there are texts to clear
        source_textarea.bind_property (
            "text",
            clear_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _text, ref _sensitive) => {
                _sensitive = ((string) _text).length > 0;
                return true;
            }
        );

        source_toolbar.notify["case-type"].connect (() => {
            Application.settings.set_enum ("source-case-type", source_toolbar.case_type);
        });
        result_toolbar.notify["case-type"].connect (() => {
            Application.settings.set_enum ("result-case-type", result_toolbar.case_type);
        });

        Application.settings.bind ("source-text", source_textarea, "text", SettingsBindFlags.DEFAULT);

        // Perform conversion when:
        //
        //  * case type of the source text is changed
        //  * case type of the result text is changed
        //  * the source text is changed
        //  * the window is initialized
        source_toolbar.dropdown_changed.connect (() => {
            result_textarea.text = do_convert (source_toolbar.case_type, source_textarea.text, result_toolbar.case_type);
        });
        result_toolbar.dropdown_changed.connect (() => {
            result_textarea.text = do_convert (source_toolbar.case_type, source_textarea.text, result_toolbar.case_type);
        });
        source_textarea.notify["text"].connect (() => {
            result_textarea.text = do_convert (source_toolbar.case_type, source_textarea.text, result_toolbar.case_type);
        });
        result_textarea.text = do_convert (source_toolbar.case_type, source_textarea.text, result_toolbar.case_type);

        source_toolbar.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (source_textarea.text);
            toast_copied ();
        });
        result_toolbar.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (result_textarea.text);
            toast_copied ();
        });

        clear_button.clicked.connect (() => {
            // Clear text in the source textarea
            // Text in the result textarea is also cleared accordingly
            source_textarea.text = "";
        });
    }

    private void toast_copied () {
        show_toast (N_("Text copied!"));
    }

    private void show_toast (string text) {
        var toast = new Adw.Toast (_(text));
        overlay.add_toast (toast);
    }

    /**
     * Perform conversion of {@link source_text} and return result text.
     *
     * @param source_case case type of source text
     * @param source_text text that is converted
     * @param result_case case type of result text
     *
     * @return text after conversion
     */
    private string do_convert (Define.CaseType source_case, string source_text, Define.CaseType result_case) {
        string result_text;

        converter.source_case = Util.to_chcase_case (source_case);
        converter.result_case = Util.to_chcase_case (result_case);

        result_text = converter.convert_case (source_text);

        return result_text;
    }
}
