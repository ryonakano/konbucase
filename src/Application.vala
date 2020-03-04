public class Application : Gtk.Application {
    private MainWindow window;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.case-converter",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new MainWindow (this);
        window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
