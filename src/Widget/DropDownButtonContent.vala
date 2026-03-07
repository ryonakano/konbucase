/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * The item in the button of a dropdown.
 *
 * The most significant difference with the default button content of a {@link Gtk.DropDown}
 * is that the label in the item is ellipsized if its text is too long.
 *
 * {{../docs/images/Widget/DropDownButtonContent/example_drop_down_button_content.png|example image of DropDownButtonContent}}
 */
public class Widget.DropDownButtonContent : Adw.Bin {
    /**
     * The label text of the item.
     */
    public string? label_text { get; set; default = null; }

    /**
     * Creates a new {@link Widget.DropDownButtonContent}.
     *
     * @return  a new {@link Widget.DropDownButtonContent}
     */
    public DropDownButtonContent () {
    }

    construct {
        var label = new Gtk.Label (label_text) {
            xalign = 0,
            ellipsize = Pango.EllipsizeMode.END,
        };

        this.bind_property ("label_text", label, "label");

        child = label;
    }
}
