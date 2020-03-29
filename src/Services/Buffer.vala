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
