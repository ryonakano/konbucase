public class Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "com.github.ryonakano.case-converter",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var target_text_buffer = new Gtk.TextBuffer (null);

        var target_text_view = new Gtk.TextView.with_buffer (target_text_buffer);
        target_text_view.wrap_mode = Gtk.WrapMode.WORD_CHAR;
        target_text_view.hexpand = true;
        target_text_view.vexpand = true;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (target_text_view);

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

        var window = new Gtk.ApplicationWindow (this);
        window.set_default_size (600, 500);
        window.set_titlebar (header);
        window.add (grid);
        window.show_all ();

        upper_case_button.clicked.connect (() => {
            target_text_view.buffer.text = target_text_view.buffer.text.up ();
        });

        lower_case_button.clicked.connect (() => {
            target_text_view.buffer.text = target_text_view.buffer.text.down ();
        });
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
