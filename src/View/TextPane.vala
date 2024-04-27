/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

[GtkTemplate (ui = "/com/github/ryonakano/konbucase/ui/text-pane.ui")]
public class TextPane : Gtk.Box {
    public signal void dropdown_changed ();
    public signal void copy_button_clicked ();

    public TextPaneModel model { get; construct; }
    public string header_label { get; construct; }
    public bool editable { get; construct; }

    [GtkChild]
    private unowned Gtk.DropDown case_dropdown;
    [GtkChild]
    private unowned Gtk.Button copy_clipboard_button;
    [GtkChild]
    private unowned GtkSource.View source_view;

    public TextPane (TextPaneModel model, string header_label, bool editable) {
        Object (
            model: model,
            header_label: header_label,
            editable: editable
        );
    }

    construct {
        case_dropdown.selected = model.case_type;

        case_dropdown.notify["selected"].connect (() => {
            model.case_type = (Define.CaseType) case_dropdown.selected;

            dropdown_changed ();
        });

        copy_clipboard_button.clicked.connect (() => {
            copy_button_clicked ();
        });

        // Make copy button insensitive when text is blank
        model.bind_property ("text", copy_clipboard_button, "sensitive",
                             BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                             (binding, from_value, ref to_value) => {
                                 var text = (string) from_value;
                                 to_value.set_boolean (text != "");
                                 return true;
                             });
    }

    // UI elements defined in .ui files can't be a property, so defines a getter method instead
    public unowned GtkSource.View get_source_view () {
        return source_view;
    }
}
