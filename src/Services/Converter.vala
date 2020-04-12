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

public class Services.Converter : Object {
    private static Converter _converter;

    private Converter () {
    }

    public static Converter get_default () {
        if (_converter == null) {
            _converter = new Converter ();
        }

        return _converter;
    }

    public string convert_case (string text, string target_case, string result_case) {
        string result_text = "";

        switch (target_case) {
            case "space_separated":
                result_text = from_space_separated (text, result_case);
                break;
            case "camel":
                result_text = from_camel_case (text, result_case);
                break;
            case "pascal":
                result_text = from_pascal_case (text, result_case);
                break;
            case "snake":
                result_text = from_snake_case (text, result_case);
                break;
            case "kebab":
                result_text = from_kebab_case (text, result_case);
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        return result_text;
    }

    private string from_space_separated (string text, string result_case) {
        MatchInfo match_info;
        string result_text = text;

        switch (result_case) {
            case "space_separated":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "camel":
                var regex = new Regex (" (.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\1");
                }

                break;
            case "pascal":
                var regex = new Regex ("( |^)(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\2");
                }

                break;
            case "snake":
                var regex = new Regex (" (.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "_\\1");
                }

                break;
            case "kebab":
                var regex = new Regex ("( )(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "-\\2");
                }

                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        return result_text;
    }

    private string from_camel_case (string text, string result_case) {
        MatchInfo match_info;
        string result_text = text;

        switch (result_case) {
            case "space_separated":
                var regex = new Regex ("(\\S)([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\1 \\2");
                }

                break;
            case "camel":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "pascal":
                var regex = new Regex ("^([a-z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\1");
                }

                break;
            case "snake":
                var regex = new Regex ("([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "_\\l\\1");
                }

                break;
            case "kebab":
                var regex = new Regex ("([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "-\\l\\1");
                }

                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        return result_text;
    }


    private string from_pascal_case (string text, string result_case) {
        MatchInfo match_info;
        string result_text = text;

        switch (result_case) {
            case "space_separated":
                var regex = new Regex ("(\\S)([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\1 \\2");
                }

                break;
            case "camel":
                var regex = new Regex ("^([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\l\\1");
                }

                break;
            case "pascal":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "snake":
                var regex = new Regex ("^([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\l\\1");
                }

                regex = new Regex ("([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "_\\l\\1");
                }

                break;
            case "kebab":
                var regex = new Regex ("^([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\l\\1");
                }

                regex = new Regex ("([A-Z])");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "-\\l\\1");
                }

                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        return result_text;
    }

    private string from_snake_case (string text, string result_case) {
        MatchInfo match_info;
        string result_text = text;

        switch (result_case) {
            case "space_separated":
                var regex = new Regex ("_(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, " \\1");
                }

                break;
            case "camel":
                var regex = new Regex ("_(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\1");
                }

                break;
            case "pascal":
                var regex = new Regex ("(_|^)(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\2");
                }

                break;
            case "snake":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "kebab":
                var regex = new Regex ("(_)(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "-\\2");
                }

                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        return result_text;
    }

    private string from_kebab_case (string text, string result_case) {
        MatchInfo match_info;
        string result_text = text;

        switch (result_case) {
            case "space_separated":
                var regex = new Regex ("-(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, " \\1");
                }

                break;
            case "camel":
                var regex = new Regex ("-(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\1");
                }

                break;
            case "pascal":
                var regex = new Regex ("(-|^)(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "\\u\\2");
                }

                break;
            case "snake":
                var regex = new Regex ("-(.)");
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, "_\\1");
                }

                break;
            case "kebab":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        return result_text;
    }
}
