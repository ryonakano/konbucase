/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class BasePane : Gtk.Box {
    public signal void dropdown_changed ();
    public signal void copy_button_clicked ();

    public string header_label { get; construct; }
    public bool editable { get; construct; }

    public Define.CaseType case_type { get; set; }
    public string text { get; set; }

    private ListStore case_listmodel;
    private GtkSource.Buffer buffer;
    private GtkSource.View source_view;
    private GtkSource.StyleSchemeManager style_scheme_manager;
    private Gtk.Settings gtk_settings;

    protected BasePane () {
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 0;

        var case_list_factory = new Gtk.SignalListItemFactory ();
        case_list_factory.bind.connect (case_list_factory_bind);
        case_list_factory.setup.connect (case_list_factory_setup);

        case_listmodel = new ListStore (typeof (CaseListItemModel));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.SPACE_SEPARATED,
            N_("Space separated"),
            N_("Each word is separated by a space")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.CAMEL,
            "camelCase",
            N_("The first character of compound words is in lowercase")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.PASCAL,
            "PascalCase",
            N_("The first character of compound words is in uppercase")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.SNAKE,
            "snake_case",
            N_("Each word is separated by an underscore")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.KEBAB,
            "kebab-case",
            N_("Each word is separated by a hyphen")
        ));
        case_listmodel.append (new CaseListItemModel (
            Define.CaseType.SENTENCE,
            "Sentence case",
            N_("The first character of the first word in the sentence is in uppercase")
        ));

        var case_expression = new Gtk.PropertyExpression (
            typeof (CaseListItemModel), null, "name"
        );
        var l10n_case_expression = new Gtk.CClosureExpression (
            typeof (string), null, { case_expression },
            (Callback) localize_str,
            null, null
        );

        var case_dropdown = new Gtk.DropDown (case_listmodel, l10n_case_expression) {
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

        buffer = new GtkSource.Buffer (null);
        style_scheme_manager = new GtkSource.StyleSchemeManager ();
        gtk_settings = Gtk.Settings.get_default ();

        source_view = new GtkSource.View.with_buffer (buffer) {
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

        this.bind_property (
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

        // Sync with buffer text
        buffer.bind_property (
            "text",
            this, "text",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );

        // Make copy button only sensitive when there are texts to copy
        this.bind_property (
            "text",
            copy_clipboard_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, text, ref sensitive) => {
                sensitive = ((string) text).length > 0;
                return true;
            }
        );

        // Apply theme changes to the source view
        gtk_settings.bind_property (
            "gtk-application-prefer-dark-theme",
            buffer, "style-scheme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, prefer_dark, ref style_scheme) => {
                if ((bool) prefer_dark) {
                    style_scheme = style_scheme_manager.get_scheme ("solarized-dark");
                } else {
                    style_scheme = style_scheme_manager.get_scheme ("solarized-light");
                }

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

        bool found = case_listmodel.find_with_equal_func (
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

        var selected_item = case_listmodel.get_item ((uint) selected) as CaseListItemModel;
        if (selected_item == null) {
            return false;
        }

        case_type.set_enum (selected_item.case_type);
        return true;
    }

    private string localize_str (string str) {
        return _(str);
    }
}
