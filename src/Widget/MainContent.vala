/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Widget.MainContent : Adw.Bin {
    private Widget.Toolbar input_toolbar;
    private Widget.TextArea input_textarea;
    private Widget.Toolbar output_toolbar;
    private Widget.TextArea output_textarea;
    private Adw.ToastOverlay overlay;

    private ulong input_case_handler;
    private ulong output_case_handler;
    private ulong input_text_handler;

    private ChCase.Converter converter;

    public MainContent () {
    }

    construct {
        /*************************************************/
        /* Input Pane                                    */
        /*************************************************/
        var clear_button = new Gtk.Button.from_icon_name ("edit-clear") {
            tooltip_text = _("Clear"),
        };

        input_toolbar = new Widget.Toolbar (_("Convert _From:")) {
            valign = Gtk.Align.START,
            case_type = (Define.CaseType) Application.settings.get_enum ("input-case-type"),
        };
        input_toolbar.append (clear_button);

        input_textarea = new Widget.TextArea (true);

        var input_pane = new Adw.ToolbarView () {
            top_bar_style = Adw.ToolbarStyle.RAISED,
            content = input_textarea,
        };
        input_pane.add_top_bar (input_toolbar);

        /*************************************************/
        /* Separator                                     */
        /*************************************************/
        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        /*************************************************/
        /* Output Pane                                   */
        /*************************************************/
        output_toolbar = new Widget.Toolbar (_("Convert _To:")) {
            valign = Gtk.Align.START,
            case_type = (Define.CaseType) Application.settings.get_enum ("output-case-type"),
        };
        // Make the text view uneditable, otherwise the app freezes
        output_textarea = new Widget.TextArea (false);

        var output_pane = new Adw.ToolbarView () {
            top_bar_style = Adw.ToolbarStyle.RAISED,
            content = output_textarea,
        };
        output_pane.add_top_bar (output_toolbar);

        var content_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        content_box.append (input_pane);
        content_box.append (separator);
        content_box.append (output_pane);

        // Use SizeGroup to keep the same size between input_pane and output_pane
        // because separator, which is not intended to be the same size with them, is also appended to content_box
        // and thus we can't set content_box.homogeneous to true.
        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.HORIZONTAL);
        size_group.add_widget (input_pane);
        size_group.add_widget (output_pane);

        overlay = new Adw.ToastOverlay () {
            child = content_box,
        };

        child = overlay;

        converter = new ChCase.Converter ();

        // The action users most frequently take is to input the input text.
        // So, forcus to the input text area by default.
        input_textarea.grab_focus ();

        // Make copy button only sensitive when there are texts to copy
        input_textarea.bind_property (
            "text",
            input_toolbar.copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, text, ref sensitive) => {
                sensitive = ((string) text).length > 0;
                return true;
            }
        );
        output_textarea.bind_property (
            "text",
            output_toolbar.copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, text, ref sensitive) => {
                sensitive = ((string) text).length > 0;
                return true;
            }
        );

        // Make clear button only sensitive when there are texts to clear
        input_textarea.bind_property (
            "text",
            clear_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _text, ref _sensitive) => {
                _sensitive = ((string) _text).length > 0;
                return true;
            }
        );

        input_toolbar.notify["case-type"].connect (() => {
            Application.settings.set_enum ("input-case-type", input_toolbar.case_type);
        });
        output_toolbar.notify["case-type"].connect (() => {
            Application.settings.set_enum ("output-case-type", output_toolbar.case_type);
        });

        Application.settings.bind ("input-text", input_textarea, "text", SettingsBindFlags.DEFAULT);

        // Perform conversion when:
        //
        //  * case type of the input text is changed
        //  * case type of the output text is changed
        //  * the input text is changed
        //  * the window is initialized
        input_case_handler = input_toolbar.dropdown_changed.connect (() => {
            output_textarea.text = do_convert (input_toolbar.case_type, input_textarea.text, output_toolbar.case_type);
        });
        output_case_handler = output_toolbar.dropdown_changed.connect (() => {
            output_textarea.text = do_convert (input_toolbar.case_type, input_textarea.text, output_toolbar.case_type);
        });
        input_text_handler = input_textarea.notify["text"].connect (() => {
            output_textarea.text = do_convert (input_toolbar.case_type, input_textarea.text, output_toolbar.case_type);
        });
        output_textarea.text = do_convert (input_toolbar.case_type, input_textarea.text, output_toolbar.case_type);

        input_toolbar.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (input_textarea.text);
            toast_copied ();
        });
        output_toolbar.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (output_textarea.text);
            toast_copied ();
        });

        clear_button.clicked.connect (() => {
            // Clear text in the input textarea
            // Text in the output textarea is also cleared accordingly
            input_textarea.text = "";
        });
    }

    public void swap () {
        // Changing value of input_toolbar.case_type, output_toolbar.case_type, and input_textarea.text causes
        // value of output_textarea.text being changed, which is unexpected convert.
        // So, disable corresponding signal handlers during swap.
        SignalHandler.block (input_toolbar, input_case_handler);
        SignalHandler.block (output_toolbar, output_case_handler);
        SignalHandler.block (input_textarea, input_text_handler);

        Define.CaseType tmp_case = input_toolbar.case_type;
        input_toolbar.case_type = output_toolbar.case_type;
        output_toolbar.case_type = tmp_case;

        string tmp_text = input_textarea.text;
        input_textarea.text = output_textarea.text;
        output_textarea.text = tmp_text;

        SignalHandler.unblock (input_toolbar, input_case_handler);
        SignalHandler.unblock (output_toolbar, output_case_handler);
        SignalHandler.unblock (input_textarea, input_text_handler);
    }

    private void toast_copied () {
        show_toast (N_("Text copied!"));
    }

    private void show_toast (string text) {
        var toast = new Adw.Toast (_(text));
        overlay.add_toast (toast);
    }

    /**
     * Perform conversion of {@link input_text} and return output text.
     *
     * @param input_case case type of input text
     * @param input_text text that is converted
     * @param output_case case type of output text
     *
     * @return text after conversion
     */
    private string do_convert (Define.CaseType input_case, string input_text, Define.CaseType output_case) {
        string output_text;

        converter.source_case = Util.to_chcase_case (input_case);
        converter.result_case = Util.to_chcase_case (output_case);

        output_text = converter.convert_case (input_text);

        return output_text;
    }
}
