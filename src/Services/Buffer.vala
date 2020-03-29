public class Services.Buffer : Gtk.SourceBuffer {
    public Buffer () {
    }

    public void case_action (Gtk.SourceChangeCaseType case_type) {
        Gtk.TextIter iter_start;
        Gtk.TextIter iter_end;
        get_iter_at_offset (out iter_start, 0);
        get_iter_at_offset (out iter_end, this.text.length);
        change_case (case_type, iter_start, iter_end);
    }
}
