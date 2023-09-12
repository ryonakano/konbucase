/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class DropDownText : Gtk.Grid {
    public signal void changed ();

    public string? active_id { get; set; }

    private class ListStoreItem : Object {
        public string id { get; construct; }
        public string? text { get; construct; }

        public ListStoreItem (string id, string? text) {
            Object (
                id: id,
                text: text
            );
        }
    }

    private class DropDownRow : Gtk.Grid {
        public Gtk.Label label;

        public DropDownRow () {
        }

        construct {
            label = new Gtk.Label (null);

            attach (label, 0, 0, 1, 1);
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

        var dropdown = new Gtk.DropDown (liststore, null) {
            factory = factory
        };

        attach (dropdown, 0, 0);

        dropdown.bind_property ("selected", this, "active-id",
                                BindingFlags.BIDIRECTIONAL,
                                (binding, from_value, ref to_value) => {
                                    var pos = (uint) from_value;
                                    var item = (ListStoreItem) liststore.get_item (pos);
                                    to_value.set_string (item.id);
                                    return true;
                                },
                                (binding, from_value, ref to_value) => {
                                    uint pos;
                                    var id = (string) from_value;
                                    liststore.find_with_equal_func (
                                        new ListStoreItem (id, null),
                                        (a, b) => {
                                            return (((ListStoreItem) a).id == ((ListStoreItem) b).id);
                                        },
                                        out pos
                                    );
                                    to_value.set_uint (pos);
                                    return true;
                                }
        );

        notify["active-id"].connect (() => { changed(); });
    }

    public new void append (string id, string text) {
        liststore.append (new ListStoreItem (id, text));
    }
}
