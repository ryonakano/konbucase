/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-main-view.h"

#include <glib/gi18n.h>

#include "kc-tool-bar.h"
#include "kc-text-area.h"

struct _KcMainView {
    GtkBox              parent_instance;
};

G_DEFINE_FINAL_TYPE (KcMainView, kc_main_view, GTK_TYPE_BOX)

static void
kc_main_view_dispose (GObject *object)
{
    G_OBJECT_CLASS (kc_main_view_parent_class)->dispose (object);
}

static void
kc_main_view_class_init (KcMainViewClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->dispose = kc_main_view_dispose;
}

static void
kc_main_view_init (KcMainView *self)
{
    GtkWidget *clear_button;
    KcToolBar *input_toolbar;
    KcTextArea *input_textarea;
    GtkWidget *input_pane;
    GtkWidget *separator;
    KcToolBar *output_toolbar;
    KcTextArea *output_textarea;
    GtkWidget *output_pane;
    g_autoptr (GtkSizeGroup) size_group;

    /*************************************************/
    /* Input Pane                                    */
    /*************************************************/
    clear_button = gtk_button_new_from_icon_name ("edit-clear");
    gtk_widget_set_tooltip_text (clear_button, _("Clear"));

    input_toolbar = kc_tool_bar_new (_("Convert _From:"));
    gtk_widget_set_valign (GTK_WIDGET (input_toolbar), GTK_ALIGN_START);
    // TODO
    //kc_tool_bar_set_case_type (input_toolbar, (Define.CaseType) Application.settings.get_enum ("input-case-type"));
    kc_tool_bar_append (input_toolbar, clear_button);

    input_textarea = kc_text_area_new (TRUE);

    input_pane = adw_toolbar_view_new ();
    adw_toolbar_view_set_top_bar_style (ADW_TOOLBAR_VIEW (input_pane), ADW_TOOLBAR_RAISED);
    adw_toolbar_view_add_top_bar (ADW_TOOLBAR_VIEW (input_pane), GTK_WIDGET (input_toolbar));
    adw_toolbar_view_set_content (ADW_TOOLBAR_VIEW (input_pane), GTK_WIDGET (input_textarea));

    /*************************************************/
    /* Separator                                     */
    /*************************************************/
    separator = gtk_separator_new (GTK_ORIENTATION_VERTICAL);

    /*************************************************/
    /* Output Pane                                   */
    /*************************************************/
    output_toolbar = kc_tool_bar_new (_("Convert _To:"));
    gtk_widget_set_valign (GTK_WIDGET (output_toolbar), GTK_ALIGN_START);
    // TODO
    //kc_tool_bar_set_case_type (output_toolbar, (Define.CaseType) Application.settings.get_enum ("output-case-type"));

    // Make the text view uneditable, otherwise the app freezes
    output_textarea = kc_text_area_new (FALSE);

    output_pane = adw_toolbar_view_new ();
    adw_toolbar_view_set_top_bar_style (ADW_TOOLBAR_VIEW (output_pane), ADW_TOOLBAR_RAISED);
    adw_toolbar_view_add_top_bar (ADW_TOOLBAR_VIEW (output_pane), GTK_WIDGET (output_toolbar));
    adw_toolbar_view_set_content (ADW_TOOLBAR_VIEW (output_pane), GTK_WIDGET (output_textarea));

    gtk_box_append (GTK_BOX (self), GTK_WIDGET (input_pane));
    gtk_box_append (GTK_BOX (self), separator);
    gtk_box_append (GTK_BOX (self), GTK_WIDGET (output_pane));

    // Use SizeGroup to keep the same size between input_pane and output_pane
    // because separator, which is not intended to be the same size with them, is also appended to ``this``
    // and thus we can't set this.homogeneous to true.
    size_group = gtk_size_group_new (GTK_SIZE_GROUP_BOTH);
    gtk_size_group_add_widget (size_group, GTK_WIDGET (input_pane));
    gtk_size_group_add_widget (size_group, GTK_WIDGET (output_pane));
}

KcMainView *
kc_main_view_new (void)
{
    return g_object_new (KC_TYPE_MAIN_VIEW,
                         "orientation", GTK_ORIENTATION_HORIZONTAL,
                         "spacing", 0,
                         NULL);
}
