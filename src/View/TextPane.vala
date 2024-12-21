/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class TextPane : Gtk.Box {
    public signal void dropdown_changed ();
    public signal void copy_button_clicked ();

    public TextPaneModel model { get; construct; }
    public string header_label { get; construct; }
    public bool editable { get; construct; }

    private GtkSource.View source_view;

    public TextPane (TextPaneModel model, string header_label, bool editable) {
        Object (
            model: model,
            header_label: header_label,
            editable: editable
        );
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 0;

        var case_list_factory = new Gtk.SignalListItemFactory ();
        case_list_factory.bind.connect (case_list_factory_bind);
        case_list_factory.setup.connect (case_list_factory_setup);

        var case_dropdown = new Gtk.DropDown (model.case_model, model.l10n_case_expression) {
            list_factory = case_list_factory
        };
        case_dropdown.selected = model.case_type;

        var case_label = new Gtk.Label (header_label) {
            use_underline = true,
            mnemonic_widget = case_dropdown
        };

        var case_info_button_icon = new Gtk.Image.from_icon_name ("dialog-information-symbolic") {
            tooltip_text = model.case_description
        };

        var copy_clipboard_button = new Gtk.Button.from_icon_name ("edit-copy") {
            tooltip_text = _("Copy to Clipboard")
        };

        var toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            valign = Gtk.Align.CENTER,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        toolbar.append (case_label);
        toolbar.append (case_dropdown);
        toolbar.append (case_info_button_icon);
        toolbar.append (copy_clipboard_button);

        source_view = new GtkSource.View.with_buffer (model.buffer) {
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            hexpand = true,
            vexpand = true,
            editable = editable
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = source_view
        };

        append (toolbar);
        append (scrolled);

        case_dropdown.notify["selected"].connect (() => {
            model.case_type = (Define.CaseType) case_dropdown.selected;

            dropdown_changed ();
        });

        copy_clipboard_button.clicked.connect (() => {
            copy_button_clicked ();
        });

        // Make copy button insensitive when text is blank
        model.bind_property (
            "text", copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, from_value, ref to_value) => {
                var text = (string) from_value;
                to_value.set_boolean (text != "");
                return true;
            }
        );
    }

    public void focus_source_view () {
        source_view.grab_focus ();
    }

    private class DropDownRow : Gtk.Box {
        public Gtk.Label title { get; set; }
        public Gtk.Label description { get; set; }

        public DropDownRow () {
        }

        construct {
            orientation = Gtk.Orientation.VERTICAL;
            spacing = 2;

            title = new Gtk.Label (null) {
                halign = Gtk.Align.START
            };
            title.add_css_class ("heading");

            description = new Gtk.Label (null) {
                halign = Gtk.Align.START
            };
            description.add_css_class ("dim-label");

            append (title);
            append (description);
        }
    }

    private void case_list_factory_setup (Object object) {
        var item = object as Gtk.ListItem;

        var row = new DropDownRow ();
        item.child = row;
    }

    private void case_list_factory_bind (Object object) {
        var item = object as Gtk.ListItem;
        var model = item.item as CaseModel;
        var row = item.child as DropDownRow;

        row.title.label = _(model.name);
        row.description.label = _(model.description);
    }
}
