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

    public string convert_case (string target_text, string target_case, string result_case) {
        MatchInfo match_info;
        string result_text = target_text;
        var patterns = new GLib.Array<string> ();
        var replace_patterns = new GLib.Array<string> ();

        switch (target_case) {
            case "space_separated":
                convert_from_space_separated (ref patterns, ref replace_patterns, result_case);
                break;
            case "camel":
                convert_from_camel_case (ref patterns, ref replace_patterns, result_case);
                break;
            case "pascal":
                convert_from_pascal_case (ref patterns, ref replace_patterns, result_case);
                break;
            case "snake":
                convert_from_snake_case (ref patterns, ref replace_patterns, result_case);
                break;
            case "kebab":
                convert_from_kebab_case (ref patterns, ref replace_patterns, result_case);
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }

        if (patterns.length != replace_patterns.length) {
            warning ("The numbers of patterns to find maching strings and ones to replace them don't match!");
        }

        try {
            for (int i = 0; i < patterns.length; i++) {
                var regex = new Regex (patterns.index (i));
                for (regex.match (result_text, 0, out match_info); match_info.matches (); match_info.next ()) {
                    result_text = regex.replace (result_text, result_text.length, 0, replace_patterns.index (i));
                }
            }
        } catch (RegexError e) {
            warning (e.message);
        }

        return result_text;
    }

    private void convert_from_space_separated (ref GLib.Array<string> patterns, ref GLib.Array<string> replace_patterns, string result_case) {
        switch (result_case) {
            case "space_separated":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "camel":
                patterns.append_val (" (.)");
                replace_patterns.append_val ("\\u\\1");
                break;
            case "pascal":
                patterns.append_val ("( |^)(.)");
                replace_patterns.append_val ("\\u\\2");
                break;
            case "snake":
                patterns.append_val (" (.)");
                replace_patterns.append_val ("_\\1");
                break;
            case "kebab":
                patterns.append_val ("( )(.)");
                replace_patterns.append_val ("-\\2");
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }
    }

    private void convert_from_camel_case (ref GLib.Array<string> patterns, ref GLib.Array<string> replace_patterns, string result_case) {
        switch (result_case) {
            case "space_separated":
                patterns.append_val ("(\\S)([A-Z])");
                replace_patterns.append_val ("\\1 \\2");
                break;
            case "camel":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "pascal":
                patterns.append_val ("^([a-z])");
                replace_patterns.append_val ("\\u\\1");
                break;
            case "snake":
                patterns.append_val ("([A-Z])");
                replace_patterns.append_val ("_\\l\\1");
                break;
            case "kebab":
                patterns.append_val ("([A-Z])");
                replace_patterns.append_val ("-\\l\\1");
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }
    }


    private void convert_from_pascal_case (ref GLib.Array<string> patterns, ref GLib.Array<string> replace_patterns, string result_case) {
        switch (result_case) {
            case "space_separated":
                patterns.append_val ("(\\S)([A-Z])");
                replace_patterns.append_val ("\\1 \\2");
                break;
            case "camel":
                patterns.append_val ("^([A-Z])");
                replace_patterns.append_val ("\\l\\1");
                break;
            case "pascal":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "snake":
                patterns.append_val ("^([A-Z])");
                replace_patterns.append_val ("\\l\\1");
                patterns.append_val ("([A-Z])");
                replace_patterns.append_val ("_\\l\\1");
                break;
            case "kebab":
                patterns.append_val ("^([A-Z])");
                replace_patterns.append_val ("\\l\\1");
                patterns.append_val ("([A-Z])");
                replace_patterns.append_val ("-\\l\\1");
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }
    }

    private void convert_from_snake_case (ref GLib.Array<string> patterns, ref GLib.Array<string> replace_patterns, string result_case) {
        switch (result_case) {
            case "space_separated":
                patterns.append_val ("_(.)");
                replace_patterns.append_val (" \\1");
                break;
            case "camel":
                patterns.append_val ("_(.)");
                replace_patterns.append_val ("\\u\\1");
                break;
            case "pascal":
                patterns.append_val ("(_|^)(.)");
                replace_patterns.append_val ("\\u\\2");
                break;
            case "snake":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            case "kebab":
                patterns.append_val ("(_)(.)");
                replace_patterns.append_val ("-\\2");
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }
    }

    private void convert_from_kebab_case (ref GLib.Array<string> patterns, ref GLib.Array<string> replace_patterns, string result_case) {
        switch (result_case) {
            case "space_separated":
                patterns.append_val ("-(.)");
                replace_patterns.append_val (" \\1");
                break;
            case "camel":
                patterns.append_val ("-(.)");
                replace_patterns.append_val ("\\u\\1");
                break;
            case "pascal":
                patterns.append_val ("(-|^)(.)");
                replace_patterns.append_val ("\\u\\2");
                break;
            case "snake":
                patterns.append_val ("-(.)");
                replace_patterns.append_val ("_\\1");
                break;
            case "kebab":
                debug ("The chosen result case is the same with target case, does nothing.");
                break;
            default:
                warning ("Unexpected case, does nothing.");
                break;
        }
    }
}
