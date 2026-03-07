/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A widget that wraps a {@link GtkSource.View}.
 *
 * {{../docs/images/Widget/TextArea/example_text_area.png|example image of TextArea}}
 */
public class Widget.TextArea : Adw.Bin {
    /**
     * Whether it's possible to modify text in the {@link GtkSource.View} that ``this`` wraps.
     */
    public bool editable { get; construct; }
    /**
     * Text in the {@link GtkSource.View} that ``this`` wraps.
     */
    public string text { get; set; }

    /**
     * The {@link GtkSource.View} that ``this`` wraps.
     */
    private GtkSource.View source_view;

    /**
     * Creates a new {@link Widget.TextArea}.
     *
     * @param editable      whether it's possible to modify text in the {@link GtkSource.View} that ``this`` wraps
     *
     * @return              a new {@link Widget.TextArea}
     */
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

    /**
     * Causes the {@link GtkSource.View} that ``this`` wraps to have the keyboard focus for the app window.
     */
    public new void grab_focus () {
        source_view.grab_focus ();
    }
}
