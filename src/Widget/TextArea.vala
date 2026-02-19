/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Widget.TextArea : Adw.Bin {
    public bool editable { get; construct; }
    public string text { get; set; }

    private GtkSource.View source_view;

    public TextArea (bool editable) {
        Object (
            editable: editable
        );
    }

    construct {
        var buffer = new GtkSource.Buffer (null);
        var style_scheme_manager = new GtkSource.StyleSchemeManager ();
        var gtk_settings = Gtk.Settings.get_default ();

        source_view = new GtkSource.View.with_buffer (buffer) {
            wrap_mode = Gtk.WrapMode.WORD_CHAR,
            hexpand = true,
            vexpand = true,
            editable = editable,
        };

        var scrolled = new Gtk.ScrolledWindow () {
            child = source_view,
        };

        child = scrolled;

        // Sync with buffer text
        buffer.bind_property (
            "text",
            this, "text",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
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

    public new void grab_focus () {
        source_view.grab_focus ();
    }
}
