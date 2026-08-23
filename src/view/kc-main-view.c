/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "config.h"

#include "kc-main-view.h"

#include <string.h>

#include <chcase.h>
#include <glib/gi18n.h>

#include "kc-case-convert.h"
#include "kc-enums.h"
#include "kc-text-area.h"
#include "kc-tool-bar.h"
#include "kc-types.h"

/**
 * KcMainView:
 *
 * The main content of the app window.
 *
 * It contains two panes; Input Pane at the start and Output Pane at the end. Both consists of a #KcToolBar
 * and a #KcTextArea.
 *
 * Input Pane aims to receive user input to convert, so text in its #KcTextArea is editable
 * and also its #KcToolBar contains a button to clear text in its #KcTextArea.
 * On the other hand, Output Pane aims to print conversion result, so text in its #KcTextArea is not editable.
 *
 * ![example image of MainView](example_main_view.png)
 */

enum {
    SIGNAL_TEXT_COPIED,

    N_SIGNALS
};

static unsigned int signals[N_SIGNALS];

struct _KcMainView {
    GtkBox              parent_instance;

    GSettings          *settings;

    KcToolBar          *input_toolbar;
    KcTextArea         *input_textarea;
    KcToolBar          *output_toolbar;
    KcTextArea         *output_textarea;

    unsigned long       input_case_handler;
    unsigned long       output_case_handler;
    unsigned long       input_text_handler;

    ChCaseConverter    *converter;
};

G_DEFINE_FINAL_TYPE (KcMainView, kc_main_view, GTK_TYPE_BOX)

static gboolean
text_area_text_to_widget_sensitive (GBinding     *binding,
                                    const GValue *text,
                                    GValue       *sensitive,
                                    void         *user_data)
{
    const char *_text;
    size_t len;

    _text = g_value_get_string (text);
    if (G_UNLIKELY (!_text)) {
        g_value_set_boolean (sensitive, FALSE);

        return TRUE;
    }

    len = strlen (_text);
    g_value_set_boolean (sensitive, len > 0);

    return TRUE;
}

static gboolean
self_orient_to_sep_orient (GBinding     *binding,
                           const GValue *self_orient,
                           GValue       *sep_orient,
                           void         *user_data)
{
    int _self_orient;
    int _sep_orient;

    _self_orient = g_value_get_enum (self_orient);
    switch (_self_orient) {
    case GTK_ORIENTATION_HORIZONTAL:
        _sep_orient = GTK_ORIENTATION_VERTICAL;
        break;
    case GTK_ORIENTATION_VERTICAL:
        _sep_orient = GTK_ORIENTATION_HORIZONTAL;
        break;
    default:
        g_critical ("Unknown Gtk.Orientation %d", _self_orient);
        return FALSE;
    }

    g_value_set_enum (sep_orient, _sep_orient);

    return TRUE;
}

static void
copy_and_notify_input (KcMainView *self)
{
    GdkClipboard *clipboard;
    g_autofree char *text = nullptr;

    clipboard = gtk_widget_get_clipboard (GTK_WIDGET (self));
    text = kc_text_area_dup_text (self->input_textarea);

    gdk_clipboard_set_text (clipboard, text);

    g_signal_emit (self, signals[SIGNAL_TEXT_COPIED], 0);
}

static void
copy_and_notify_output (KcMainView *self)
{
    GdkClipboard *clipboard;
    g_autofree char *text = nullptr;

    clipboard = gtk_widget_get_clipboard (GTK_WIDGET (self));
    text = kc_text_area_dup_text (self->output_textarea);

    gdk_clipboard_set_text (clipboard, text);

    g_signal_emit (self, signals[SIGNAL_TEXT_COPIED], 0);
}

static void
save_input_case_type (KcMainView *self)
{
    KcCaseType case_type;

    case_type = kc_tool_bar_get_case_type (self->input_toolbar);
    g_settings_set_enum (self->settings, "input-case-type", case_type);
}

static void
save_output_case_type (KcMainView *self)
{
    KcCaseType case_type;

    case_type = kc_tool_bar_get_case_type (self->output_toolbar);
    g_settings_set_enum (self->settings, "output-case-type", case_type);
}

static void
do_convert (KcMainView *self)
{
    KcCaseType input_case;
    g_autofree char *input_text = nullptr;
    KcCaseType output_case;
    g_autofree char *result = nullptr;

    input_case = kc_tool_bar_get_case_type (self->input_toolbar);
    input_text = kc_text_area_dup_text (self->input_textarea);
    output_case = kc_tool_bar_get_case_type (self->output_toolbar);

    result = kc_case_convert_do_convert (self->converter, input_case, input_text, output_case);

    kc_text_area_set_text (self->output_textarea, result);
}

static void
kc_main_view_dispose (GObject *object)
{
    KcMainView *self = KC_MAIN_VIEW (object);

    gtk_widget_dispose_template (GTK_WIDGET (self), KC_TYPE_MAIN_VIEW);

    g_clear_object (&self->settings);
    g_clear_object (&self->converter);

    G_OBJECT_CLASS (kc_main_view_parent_class)->dispose (object);
}

static void
kc_main_view_class_init (KcMainViewClass *klass)
{
    GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (klass);
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    gtk_widget_class_set_template_from_resource (widget_class, "/com/github/ryonakano/konbucase/view/kc-main-view.ui");
    //gtk_widget_class_bind_template_child (widget_class, KcMainView, overlay);
    //gtk_widget_class_bind_template_callback (widget_class, notify_is_active_cb);

    object_class->dispose = kc_main_view_dispose;

    /**
     * KcMainView::text-copied:
     *
     * Emitted when text in a #KcTextArea is copied to the clipboard.
     */
    signals[SIGNAL_TEXT_COPIED] =
        g_signal_new ("text-copied",
                      G_TYPE_FROM_CLASS (klass),
                      G_SIGNAL_RUN_LAST,
                      0,
                      nullptr,
                      nullptr,
                      nullptr,
                      G_TYPE_NONE,
                      0);
}

static void
kc_main_view_init (KcMainView *self)
{
    GtkWidget *clear_button;
    KcCaseType input_case_type;
    GtkWidget *input_pane;

    GtkWidget *separator;

    KcCaseType output_case_type;
    GtkWidget *output_pane;

    g_autoptr(GtkSizeGroup) size_group = nullptr;

    GtkWidget *input_copy_button;
    GtkWidget *output_copy_button;

    gtk_widget_init_template (GTK_WIDGET (self));

    self->settings = g_settings_new (APP_ID);

#if 0
    /*************************************************/
    /* Input Pane                                    */
    /*************************************************/
    input_case_type = g_settings_get_enum (self->settings, "input-case-type");
    kc_tool_bar_set_case_type (self->input_toolbar, input_case_type);

    /*************************************************/
    /* Output Pane                                   */
    /*************************************************/
    output_case_type = g_settings_get_enum (self->settings, "output-case-type");
    kc_tool_bar_set_case_type (self->output_toolbar, output_case_type);

    self->converter = chcase_converter_new ();

    // The action users most frequently take is to input the input text.
    // So, forcus to the input text area by default.
    gtk_widget_grab_focus (GTK_WIDGET (self->input_textarea));

    // Make copy button only sensitive when there are texts to copy
    input_copy_button = kc_tool_bar_get_copy_button (self->input_toolbar);
    g_object_bind_property_full (G_OBJECT (self->input_textarea), "text",
                                 G_OBJECT (input_copy_button), "sensitive",
                                 G_BINDING_DEFAULT | G_BINDING_SYNC_CREATE,
                                 text_area_text_to_widget_sensitive,
                                 nullptr,
                                 nullptr,
                                 nullptr);
    output_copy_button = kc_tool_bar_get_copy_button (self->output_toolbar);
    g_object_bind_property_full (G_OBJECT (self->output_textarea), "text",
                                 G_OBJECT (output_copy_button), "sensitive",
                                 G_BINDING_DEFAULT | G_BINDING_SYNC_CREATE,
                                 text_area_text_to_widget_sensitive,
                                 nullptr,
                                 nullptr,
                                 nullptr);

    g_object_bind_property_full (G_OBJECT (self), "orientation",
                                 G_OBJECT (separator), "orientation",
                                 G_BINDING_DEFAULT | G_BINDING_SYNC_CREATE,
                                 self_orient_to_sep_orient,
                                 nullptr,
                                 nullptr,
                                 nullptr);

    // Make clear button only sensitive when there are texts to clear
    g_object_bind_property_full (G_OBJECT (self->input_textarea), "text",
                                 G_OBJECT (clear_button), "sensitive",
                                 G_BINDING_DEFAULT | G_BINDING_SYNC_CREATE,
                                 text_area_text_to_widget_sensitive,
                                 nullptr,
                                 nullptr,
                                 nullptr);

    g_signal_connect_swapped (self->input_toolbar, "notify::case-type", G_CALLBACK (save_input_case_type), self);
    g_signal_connect_swapped (self->output_toolbar, "notify::case-type", G_CALLBACK (save_output_case_type), self);

    g_settings_bind (self->settings, "input-text", self->input_textarea, "text", G_SETTINGS_BIND_DEFAULT);

    // Perform conversion when:
    //
    //  * case type of the input text is changed
    //  * case type of the output text is changed
    //  * the input text is changed
    //  * the window is initialized
    self->input_case_handler = g_signal_connect_swapped (self->input_toolbar, "drop-down-changed",
                                                         G_CALLBACK (do_convert), self);
    self->output_case_handler = g_signal_connect_swapped (self->output_toolbar, "drop-down-changed",
                                                         G_CALLBACK (do_convert), self);
    self->input_text_handler = g_signal_connect_swapped (self->input_textarea, "notify::text",
                                                         G_CALLBACK (do_convert), self);
    do_convert (self);

    g_signal_connect_swapped (self->input_toolbar, "copy-button-clicked", G_CALLBACK (copy_and_notify_input), self);
    g_signal_connect_swapped (self->output_toolbar, "copy-button-clicked", G_CALLBACK (copy_and_notify_output), self);

    // Clear text in the input textarea
    // Text in the output textarea is also cleared accordingly
    g_signal_connect_swapped (clear_button, "clicked", G_CALLBACK (kc_text_area_clear_text), self->input_textarea);
#endif
}

/**
 * kc_main_view_swap:
 * @self: a #KcMainView
 *
 * Swaps values of #KcToolBar:case-type and #KcTextArea:text between input and output.
 */
void
kc_main_view_swap (KcMainView *self)
{
    KcCaseType old_input_case;
    KcCaseType old_output_case;
    g_autofree char *old_input_text = nullptr;
    g_autofree char *old_output_text = nullptr;

    g_return_if_fail (KC_IS_MAIN_VIEW (self));

    // Changing value of input_toolbar.case_type, output_toolbar.case_type, and input_textarea.text causes
    // value of output_textarea.text being changed, which is unexpected convert.
    // So, disable corresponding signal handlers during swap.
    g_signal_handler_block (self->input_toolbar, self->input_case_handler);
    g_signal_handler_block (self->output_toolbar, self->output_case_handler);
    g_signal_handler_block (self->input_textarea, self->input_text_handler);

    old_input_case = kc_tool_bar_get_case_type (self->input_toolbar);
    old_output_case = kc_tool_bar_get_case_type (self->output_toolbar);

    kc_tool_bar_set_case_type (self->input_toolbar, old_output_case);
    kc_tool_bar_set_case_type (self->output_toolbar, old_input_case);

    old_input_text = kc_text_area_dup_text (self->input_textarea);
    old_output_text = kc_text_area_dup_text (self->output_textarea);
    kc_text_area_set_text (self->input_textarea, old_output_text);
    kc_text_area_set_text (self->output_textarea, old_input_text);

    g_signal_handler_unblock (self->input_toolbar, self->input_case_handler);
    g_signal_handler_unblock (self->output_toolbar, self->output_case_handler);
    g_signal_handler_unblock (self->input_textarea, self->input_text_handler);
}


/**
 * kc_main_view_new:
 *
 * Creates a new #KcMainView.
 *
 * Returns: (transfer full): the newly created #KcMainView
 */
KcMainView *
kc_main_view_new (void)
{
    return g_object_new (KC_TYPE_MAIN_VIEW,
                         "orientation", GTK_ORIENTATION_HORIZONTAL,
                         "spacing", 0,
                         nullptr);
}
