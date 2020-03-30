/*
* Copyright 2020 Ryo Nakano
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

public class MainWindow : Gtk.ApplicationWindow {
    private Services.Buffer target_source_buffer;

    private Gtk.Grid buttons_grid;
    private Gtk.ToolButton copy_clipboard_button;
    private Gtk.ToolButton undo_button;
    private Gtk.ToolButton redo_button;

    public MainWindow (Application app) {
        Object (
            application: app,
            width_request: 600,
            height_request: 500
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/konbucase/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        target_source_buffer = new Services.Buffer ();

        var target_source_view = new Gtk.SourceView.with_buffer (target_source_buffer);
        target_source_view.get_style_context ().add_class ("text-view");
        target_source_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        target_source_view.hexpand = true;
        target_source_view.vexpand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (target_source_view);

        // FIXME: Support Sentence case and Title Case
        var lower_case_button = new Gtk.Button.with_label ("lower case");
        var upper_case_button = new Gtk.Button.with_label ("UPPER CASE");
        var capitalized_case_button = new Gtk.Button.with_label ("Capitalized Case");

        buttons_grid = new Gtk.Grid ();
        buttons_grid.margin = 12;
        buttons_grid.column_spacing = 12;
        buttons_grid.halign = Gtk.Align.CENTER;
        buttons_grid.attach (lower_case_button, 0, 1, 1, 1);
        buttons_grid.attach (upper_case_button, 1, 1, 1, 1);
        buttons_grid.attach (capitalized_case_button, 2, 1, 1, 1);

        var grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("toolbar");
        grid.margin = 0;
        grid.attach (scrolled, 0, 0, 1, 1);
        grid.attach (buttons_grid, 0, 1, 1, 1);

        var copy_clipboard_button_icon = new Gtk.Image.from_icon_name ("edit-copy", Gtk.IconSize.SMALL_TOOLBAR);
        copy_clipboard_button = new Gtk.ToolButton (copy_clipboard_button_icon, null);
        copy_clipboard_button.sensitive = false;
        copy_clipboard_button.tooltip_text = "Copy to Clipboard";

        var undo_button_icon = new Gtk.Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
        undo_button = new Gtk.ToolButton (undo_button_icon, null);
        undo_button.sensitive = false;
        undo_button.tooltip_text = "Undo case change";

        var redo_button_icon = new Gtk.Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
        redo_button = new Gtk.ToolButton (redo_button_icon, null);
        redo_button.sensitive = false;
        redo_button.tooltip_text = "Redo case change";

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = "KonbuCase";
        header.pack_start (copy_clipboard_button);
        header.pack_end (redo_button);
        header.pack_end (undo_button);

        set_titlebar (header);
        add (grid);

        update_buttons ();

        target_source_buffer.notify["text"].connect (() => {
            update_buttons ();
        });

        upper_case_button.clicked.connect (() => {
            target_source_buffer.case_action (Gtk.SourceChangeCaseType.UPPER);
            update_header_buttons ();
        });

        lower_case_button.clicked.connect (() => {
            target_source_buffer.case_action (Gtk.SourceChangeCaseType.LOWER);
            update_header_buttons ();
        });

        capitalized_case_button.clicked.connect (() => {
            target_source_buffer.case_action (Gtk.SourceChangeCaseType.TITLE);
            update_header_buttons ();
        });

        copy_clipboard_button.clicked.connect (() => {
            Gtk.Clipboard.get_default (Gdk.Display.get_default ()).set_text (target_source_buffer.text, -1);
        });

        undo_button.clicked.connect (() => {
            if (!target_source_buffer.can_undo) {
                return;
            }

            target_source_buffer.undo ();
            update_header_buttons ();
        });

        redo_button.clicked.connect (() => {
            if (!target_source_buffer.can_redo) {
                return;
            }

            target_source_buffer.redo ();
            update_header_buttons ();
        });
    }

    private void update_header_buttons () {
        undo_button.sensitive = target_source_buffer.can_undo;
        redo_button.sensitive = target_source_buffer.can_redo;
    }

    private void update_buttons () {
        bool has_text = target_source_buffer.text != "";

        copy_clipboard_button.sensitive = has_text;
        foreach (var buttons in buttons_grid.get_children ()) {
            buttons.sensitive = has_text;
        }
    }
}
