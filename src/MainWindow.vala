public class MainWindow : Gtk.ApplicationWindow {
    private Services.Buffer target_source_buffer;

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
        target_source_buffer = new Services.Buffer ();

        var target_source_view = new Gtk.SourceView.with_buffer (target_source_buffer);
        target_source_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        target_source_view.hexpand = true;
        target_source_view.vexpand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (target_source_view);

        // FIXME: Support Sentence case and Title Case
        var lower_case_button = new Gtk.Button.with_label ("lower case");
        var upper_case_button = new Gtk.Button.with_label ("UPPER CASE");
        var capitalized_case_button = new Gtk.Button.with_label ("Capitalized Case");

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.attach (scrolled, 0, 0, 6, 1);
        grid.attach (lower_case_button, 1, 1, 1, 1);
        grid.attach (upper_case_button, 2, 1, 1, 1);
        grid.attach (capitalized_case_button, 3, 1, 1, 1);

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
        header.title = "Case Converter";
        header.pack_start (copy_clipboard_button);
        header.pack_end (redo_button);
        header.pack_end (undo_button);

        set_titlebar (header);
        add (grid);

        target_source_buffer.notify["text"].connect (() => {
            copy_clipboard_button.sensitive = target_source_buffer.text != "";
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
}
