/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Widget.DropDownRow : Gtk.Box {
    public Gtk.Label title { get; set; }
    public Gtk.Label description { get; set; }

    public DropDownRow () {
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 2;

        title = new Gtk.Label (null) {
            width_chars = 25,
            wrap = true,
            xalign = 0,
        };
        title.add_css_class ("heading");

        description = new Gtk.Label (null) {
            width_chars = 25,
            wrap = true,
            xalign = 0,
        };
        description.add_css_class ("dim-label");

        append (title);
        append (description);
    }
}
