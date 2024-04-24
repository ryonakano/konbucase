/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/View/ComboEntry.ui")]
public class ComboEntry : Gtk.Box {
    /** Notify change of currently selected item in {@link case_dropdown}. */
    public signal void dropdown_changed ();
    /** Notify change of text in {@link source_view}. */
    public signal void text_changed ();
    /** Notify that text in {@link source_view} is copied. */
    public signal void text_copied ();

    public Define.TextType text_type { get; construct; }
    public string description { get; construct; }
    public bool editable { get; construct; }
    public string text {
        get {
            return model.text;
        }
        set {
            model.text = value;
        }
    }
    public Define.CaseType case_type {
        get {
            return model.case_type;
        }
    }

    [GtkChild]
    private unowned Gtk.DropDown case_dropdown;
    [GtkChild]
    private unowned Gtk.Image case_info_button_icon;
    [GtkChild]
    private unowned Gtk.Button copy_clipboard_button;
    [GtkChild]
    private unowned GtkSource.View source_view;

    private struct CaseInfo {
        /** Tooltip text for {@link case_info_button_icon}. */
        string info_text;
    }
    private const CaseInfo[] CASE_INFO_TBL = {
        { N_("Each word is separated by a space") }, // Define.CaseType.SPACE_SEPARATED
        { N_("The first character of compound words is in lowercase") }, // Define.CaseType.CAMEL
        { N_("The first character of compound words is in uppercase") }, // Define.CaseType.PASCAL
        { N_("Each word is separated by an underscore") }, // Define.CaseType.SNAKE
        { N_("Each word is separated by a hyphen") }, // Define.CaseType.KEBAB
        { N_("The first character of the first word in the sentence is in uppercase") }, // Define.CaseType.SENTENCE
    };

    private ComboEntryModel model;

    public ComboEntry (Define.TextType text_type, string description, bool editable) {
        Object (
            text_type: text_type,
            description: description,
            editable: editable
        );
    }

    construct {
        model = new ComboEntryModel (text_type);

        case_dropdown.selected = model.case_type;

        source_view.buffer = model.buffer;

        case_dropdown.notify["selected"].connect (() => {
            model.case_type = (Define.CaseType) case_dropdown.selected;

            dropdown_changed ();
        });

        copy_clipboard_button.clicked.connect (() => {
            get_clipboard ().set_text (model.text);
            text_copied ();
        });

        model.bind_property ("text", copy_clipboard_button, "sensitive",
                             BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                             (binding, from_value, ref to_value) => {
                                 var text = (string) from_value;
                                 to_value.set_boolean (text != "");
                                 return true;
                             });

        model.bind_property ("case-type", case_info_button_icon, "tooltip-text",
                             BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                             (binding, from_value, ref to_value) => {
                                 var case_type = (Define.CaseType) from_value;
                                 to_value.set_string (_(CASE_INFO_TBL[case_type].info_text));
                                 return true;
                             });

        model.notify["text"].connect (() => {
            text_changed ();
        });
    }

    // UI elements defined in .ui files can't be a property, so defines a getter method instead
    public unowned GtkSource.View get_source_view () {
        return source_view;
    }
}
