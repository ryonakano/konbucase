public class MainWindow  : Gtk.ApplicationWindow {
    public MainWindow (Application app) {
        Object (
            application: app,
            width_request: 600,
            height_request: 500
        );
    }

    construct {
        var target_source_buffer = new Gtk.SourceBuffer (null);

        var target_source_view = new Gtk.SourceView.with_buffer (target_source_buffer);
        target_source_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        target_source_view.hexpand = true;
        target_source_view.vexpand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (target_source_view);

        var sentence_case_button = new Gtk.Button.with_label ("Sentence case");
        var lower_case_button = new Gtk.Button.with_label ("lower case");
        var upper_case_button = new Gtk.Button.with_label ("UPPER CASE");
        var capitalized_case_button = new Gtk.Button.with_label ("Capitalized Case");
        var title_case_button = new Gtk.Button.with_label ("Title Case");

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.attach (scrolled, 0, 0, 6, 1);
        grid.attach (sentence_case_button, 1, 1, 1, 1);
        grid.attach (lower_case_button, 2, 1, 1, 1);
        grid.attach (upper_case_button, 3, 1, 1, 1);
        grid.attach (capitalized_case_button, 4, 1, 1, 1);
        grid.attach (title_case_button, 5, 1, 1, 1);

        var undo_button_icon = new Gtk.Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
        var undo_button = new Gtk.ToolButton (undo_button_icon, null);
        undo_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>Z"}, "Undo");

        var redo_button_icon = new Gtk.Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
        var redo_button = new Gtk.ToolButton (redo_button_icon, null);
        redo_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>Z"}, "Redo");

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;
        header.title = "Case Converter";
        header.pack_end (redo_button);
        header.pack_end (undo_button);

        set_titlebar (header);
        add (grid);

        upper_case_button.clicked.connect (() => {
            Gtk.TextIter iter_start;
            Gtk.TextIter iter_end;
            target_source_buffer.get_iter_at_offset (out iter_start, 0);
            target_source_buffer.get_iter_at_offset (out iter_end, target_source_buffer.text.length);
            target_source_buffer.change_case (Gtk.SourceChangeCaseType.UPPER, iter_start, iter_end);
        });

        lower_case_button.clicked.connect (() => {
            Gtk.TextIter iter_start;
            Gtk.TextIter iter_end;
            target_source_buffer.get_iter_at_offset (out iter_start, 0);
            target_source_buffer.get_iter_at_offset (out iter_end, target_source_buffer.text.length);
            target_source_buffer.change_case (Gtk.SourceChangeCaseType.LOWER, iter_start, iter_end);
        });

        title_case_button.clicked.connect (() => {
            Gtk.TextIter iter_start;
            Gtk.TextIter iter_end;
            target_source_buffer.get_iter_at_offset (out iter_start, 0);
            target_source_buffer.get_iter_at_offset (out iter_end, target_source_buffer.text.length);
            target_source_buffer.change_case (Gtk.SourceChangeCaseType.TITLE, iter_start, iter_end);
        });
    }
}
