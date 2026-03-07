/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A row of a dropdown with a title and description text.
 *
 * {{../docs/images/Widget/DropDownRow/example_drop_down_row.png|example image of DropDownRow}}
 */
public class Widget.DropDownRow : Gtk.Box {
    /**
     * The title of the row.
     */
    public Gtk.Label title { get; set; }
    /**
     * The description of the row.
     */
    public Gtk.Label description { get; set; }

    /**
     * Creates a new {@link Widget.DropDownRow}.
     *
     * @return  a new {@link Widget.DropDownRow}
     */
    public DropDownRow () {
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 2;

        title = new Gtk.Label (null) {
            hexpand = true,
            width_chars = 25,
            wrap = true,
            xalign = 0,
        };
        title.add_css_class ("heading");

        description = new Gtk.Label (null) {
            hexpand = true,
            width_chars = 25,
            wrap = true,
            xalign = 0,
        };
        description.add_css_class ("dim-label");

        append (title);
        append (description);
    }
}
