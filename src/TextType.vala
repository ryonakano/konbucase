/*
* Copyright 2020-2021 Ryo Nakano
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

public enum TextType {
    SOURCE,
    RESULT;

    public string get_case_label () {
        switch (this) {
            case TextType.SOURCE:
                return _("Convert from:");
            case TextType.RESULT:
                return _("Convert to:");
            default:
                assert_not_reached ();
        }
    }

    public string get_identifier () {
        switch (this) {
            case TextType.SOURCE:
                return "source";
            case TextType.RESULT:
                return "result";
            default:
                assert_not_reached ();
        }
    }
}
