/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/combo-entry.ui")]
public class ComboEntry : Gtk.Box {
    public signal void dropdown_changed ();
    public signal void text_changed ();
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

        case_info_button_icon.tooltip_text = get_info_button_tooltip (model.case_type);

        source_view.buffer = model.buffer;

        case_dropdown.notify["selected"].connect (() => {
            model.case_type = (Define.CaseType) case_dropdown.selected;
            case_info_button_icon.tooltip_text = get_info_button_tooltip (model.case_type);

            dropdown_changed ();
        });

        model.bind_property ("text", copy_clipboard_button, "sensitive",
                             BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                             (binding, from_value, ref to_value) => {
                                 var text = (string) from_value;
                                 to_value.set_boolean (text != "");
                                 return true;
                             });

        model.notify["text"].connect (() => {
            text_changed ();
        });

        copy_clipboard_button.clicked.connect (() => {
            get_clipboard ().set_text (model.text);
            text_copied ();
        });
    }

    private string get_info_button_tooltip (Define.CaseType case_type) {
        switch (case_type) {
            case Define.CaseType.SPACE_SEPARATED:
                return _("Each word is separated by a space");
            case Define.CaseType.CAMEL:
                return _("The first character of compound words is in lowercase");
            case Define.CaseType.PASCAL:
                return _("The first character of compound words is in uppercase");
            case Define.CaseType.SNAKE:
                return _("Each word is separated by an underscore");
            case Define.CaseType.KEBAB:
                return _("Each word is separated by a hyphen");
            case Define.CaseType.SENTENCE:
                return _("The first character of the first word in the sentence is in uppercase");
            default:
                warning ("Unexpected case, no tooltip is shown.");
                return "";
        }
    }

    public unowned GtkSource.View get_source_view () {
        return source_view;
    }
}
