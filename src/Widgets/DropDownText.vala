/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public sealed class DropDownText : Gtk.Grid {
    public signal void changed ();

    public string? active_id { get; set; }

    public Gtk.DropDown dropdown { get; set; }

    private class ListStoreItem : Object {
        public string id { get; construct; }
        public string text { get; construct; }

        public ListStoreItem (string id, string text) {
            Object (
                id: id,
                text: text
            );
        }
    }

    private class DropDownRow : Gtk.Grid {
        public Gtk.Label label { get; set; }

        public DropDownRow () {
        }

        construct {
            label = new Gtk.Label (null);

            attach (label, 0, 0);
        }
    }

    private ListStore liststore;

    public DropDownText () {
    }

    construct {
        liststore = new ListStore (typeof (ListStoreItem));

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect ((obj) => {
            var list_item = obj as Gtk.ListItem;

            var row = new DropDownRow ();
            list_item.child = row;
        });
        factory.bind.connect ((obj) => {
            var list_item = obj as Gtk.ListItem;
            var item = list_item.item as ListStoreItem;
            var row = list_item.child as DropDownRow;

            row.label.label = item.text;
        });

        dropdown = new Gtk.DropDown (liststore, null) {
            factory = factory
        };

        attach (dropdown, 0, 0);

        dropdown.bind_property ("selected", this, "active-id",
                                BindingFlags.BIDIRECTIONAL,
                                (binding, from_value, ref to_value) => {
                                    var pos = (uint) from_value;
                                    // No item is selected
                                    if (pos == Gtk.INVALID_LIST_POSITION) {
                                        to_value.set_string (null);
                                        return false;
                                    }

                                    var item = (ListStoreItem) liststore.get_item (pos);
                                    to_value.set_string (item.id);
                                    return true;
                                },
                                (binding, from_value, ref to_value) => {
                                    uint pos;
                                    var id = (string) from_value;
                                    liststore.find_with_equal_func (
                                        // Find with id
                                        new ListStoreItem (id, ""),
                                        (a, b) => {
                                            return (((ListStoreItem) a).id == ((ListStoreItem) b).id);
                                        },
                                        out pos
                                    );
                                    to_value.set_uint (pos);
                                    return true;
                                }
        );

        notify["active-id"].connect (() => { changed (); });
    }

    public new void append (string id, string text) {
        liststore.append (new ListStoreItem (id, text));
    }

    public string? get_active_text () {
        Object? selected_item = dropdown.selected_item;
        if (selected_item == null) {
            return null;
        }

        return ((ListStoreItem) selected_item).text;
    }

    public void insert (int position, string id, string text) {
        if (position < 0) {
            append (id, text);
        } else {
            liststore.insert (position, new ListStoreItem (id, text));
        }
    }

    public void prepend (string id, string text) {
        insert (0, id, text);
    }

    public new void remove (int position) {
        liststore.remove (position);
    }

    public void remove_all () {
        liststore.remove_all ();
    }
}
