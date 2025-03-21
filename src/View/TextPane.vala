/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
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

        var case_dropdown = new Gtk.DropDown (model.case_listmodel, model.l10n_case_expression) {
            list_factory = case_list_factory
        };

        var case_label = new Gtk.Label (header_label) {
            use_underline = true,
            mnemonic_widget = case_dropdown
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

        model.bind_property (
            "case-type",
            case_dropdown, "selected",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
            case_to_selected,
            selected_to_case
        );

        case_dropdown.notify["selected"].connect (() => {
            dropdown_changed ();
        });

        copy_clipboard_button.clicked.connect (() => {
            copy_button_clicked ();
        });

        // Make copy button only sensitive when there are texts to copy
        model.bind_property (
            "text",
            copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, text, ref sensitive) => {
                sensitive = ((string) text).length > 0;
                return true;
            }
        );
    }

    public void focus_source_view () {
        source_view.grab_focus ();
    }

    private void case_list_factory_setup (Object object) {
        var item = object as Gtk.ListItem;

        var row = new DropDownRow ();
        item.child = row;
    }

    private void case_list_factory_bind (Object object) {
        var item = object as Gtk.ListItem;
        var model = item.item as CaseListItemModel;
        var row = item.child as DropDownRow;

        row.title.label = _(model.name);
        row.description.label = _(model.description);
    }

    private bool case_to_selected (Binding binding, Value case_type, ref Value selected) {
        uint pos;

        bool found = model.case_listmodel.find_with_equal_func (
            // Find with case type
            new CaseListItemModel ((Define.CaseType) case_type, "", ""),
            (a, b) => {
                return ((CaseListItemModel) a).case_type == ((CaseListItemModel) b).case_type;
            },
            out pos
        );

        if (!found) {
            return false;
        }

        selected.set_uint (pos);
        return true;
    }

    private bool selected_to_case (Binding binding, Value selected, ref Value case_type) {
        // No item is selected
        if (selected == Gtk.INVALID_LIST_POSITION) {
            return false;
        }

        var selected_item = model.case_listmodel.get_item ((uint) selected) as CaseListItemModel;
        if (selected_item == null) {
            return false;
        }

        case_type.set_enum (selected_item.case_type);
        return true;
    }
}
