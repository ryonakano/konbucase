/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class View.Pane.SourcePane : BasePane {
    public signal void clear_button_clicked ();

    public SourcePane () {
        Object (
            header_label: _("Convert _From:"),
            editable: true
        );
    }

    construct {
        case_type = (Define.CaseType) Application.settings.get_enum ("source-case-type");

        var clear_button = new Gtk.Button.from_icon_name ("edit-clear") {
            tooltip_text = _("Clear")
        };

        unowned var toolbar_custom_area = get_toolbar_custom_area ();
        toolbar_custom_area.append (clear_button);

        clear_button.clicked.connect (() => {
            clear_button_clicked ();
        });

        // Make clear button only sensitive when there are texts to clear
        this.bind_property (
            "text",
            clear_button, "sensitive",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _text, ref _sensitive) => {
                _sensitive = ((string) _text).length > 0;
                return true;
            }
        );

        notify["case-type"].connect (() => {
            Application.settings.set_enum ("source-case-type", case_type);
        });

        Application.settings.bind ("source-text", this, "text", SettingsBindFlags.DEFAULT);
    }
}
