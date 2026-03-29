/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * The main content of the app window.
 *
 * It contains two panes; Input Pane at the start and Output Pane at the end. Both consists of a {@link Widget.Toolbar}
 * and a {@link Widget.TextArea}.
 *
 * Input Pane aims to receive user input to convert, so text in its {@link Widget.TextArea} is editable
 * and also its {@link Widget.Toolbar} contains a button to clear text in its {@link Widget.TextArea}.<<BR>>
 * On the other hand, Output Pane aims to print conversion result, so text in its {@link Widget.TextArea}
 * is not editable.
 *
 * {{../docs/images/View/MainView/example_main_view.png|example image of MainView}}
 */
public class View.MainView : Gtk.Box {
    /**
     * Emitted when text in a {@link Widget.TextArea} that ``this`` contains is copied to the clipboard.
     */
    public signal void text_copied ();

    /**
     * The toolbar for input text.
     */
    private Widget.Toolbar input_toolbar;
    /**
     * The textarea for input text.
     */
    private Widget.TextArea input_textarea;
    /**
     * The toolbar for output text.
     */
    private Widget.Toolbar output_toolbar;
    /**
     * The textarea for output text.
     */
    private Widget.TextArea output_textarea;

    /**
     * ID of the lambda that handles change of case type of input text.
     */
    private ulong input_case_handler;
    /**
     * ID of the lambda that handles change of case type of output text.
     */
    private ulong output_case_handler;
    /**
     * ID of the lambda that handles change of input text.
     */
    private ulong input_text_handler;

    /**
     * A library class that handles conversion of text.
     *
     * Note: See [[https://ryonakano.github.io/chcase/]] for the documentation of ChCase.
     */
    private ChCase.Converter converter;

    /**
     * Creates a new {@link View.MainView}.
     *
     * @return  a new {@link View.MainView}
     */
    public MainView () {
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

        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 0;
        append (input_pane);
        append (separator);
        append (output_pane);

        // Use SizeGroup to keep the same size between input_pane and output_pane
        // because separator, which is not intended to be the same size with them, is also appended to ``this``
        // and thus we can't set this.homogeneous to true.
        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.BOTH);
        size_group.add_widget (input_pane);
        size_group.add_widget (output_pane);

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

        this.bind_property ("orientation",
            separator, "orientation",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _this_orient, ref _sep_orient) => {
                var orient = (Gtk.Orientation) _this_orient;

                switch (orient) {
                    case Gtk.Orientation.HORIZONTAL:
                        _sep_orient = Gtk.Orientation.VERTICAL;
                        break;
                    case Gtk.Orientation.VERTICAL:
                        _sep_orient = Gtk.Orientation.HORIZONTAL;
                        break;
                    default:
                        critical ("Unknown Gtk.Orientation %d", orient);
                        return false;
                }

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
            text_copied ();
        });
        output_toolbar.copy_button_clicked.connect (() => {
            get_clipboard ().set_text (output_textarea.text);
            text_copied ();
        });

        clear_button.clicked.connect (() => {
            // Clear text in the input textarea
            // Text in the output textarea is also cleared accordingly
            input_textarea.text = "";
        });
    }

    /**
     * Swaps values of {@link Widget.Toolbar.case_type} and {@link Widget.TextArea.text} between input and output.
     */
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

    /**
     * Converts case of a piece of text.
     *
     * @param input_case    case type of input text
     * @param input_text    text that is converted
     * @param output_case   case type of output text
     *
     * @return              text after conversion
     */
    private string do_convert (Define.CaseType input_case, string input_text, Define.CaseType output_case) {
        string output_text;

        converter.input_case = Util.Convert.to_chcase_case (input_case);
        converter.output_case = Util.Convert.to_chcase_case (output_case);

        output_text = converter.convert_case (input_text);

        return output_text;
    }
}
