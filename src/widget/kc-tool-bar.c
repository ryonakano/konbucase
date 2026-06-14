/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-tool-bar.h"

#include <glib/gi18n.h>
#include <gtk/gtk.h>

#include "kc-case-list-item.h"
#include "kc-dropdown-button-content.h"
#include "kc-dropdown-row.h"

#include "kc-types.h"
#include "kc-enums.h"

enum {
    L10N_CASE_EXP_PARAM_STR,

    N_L10N_CASE_EXP_PARAMS
};

enum {
    PROP_0,

    PROP_HEADER_LABEL,
    PROP_CASE_TYPE,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

struct _KcToolBar {
    AdwBin          parent_instance;

    gchar          *header_label;
    GtkWidget      *case_label;
    KcCaseType      case_type;
    GtkWidget      *copy_clipboard_button;

    GtkWidget      *toolbar_custom_area;
};

G_DEFINE_FINAL_TYPE (KcToolBar, kc_tool_bar, ADW_TYPE_BIN)

static const char *
localize_str (const char *str)
{
    return _(str);
}

static void
kc_tool_bar_get_property (GObject      *object,
                          uint          prop_id,
                          GValue       *value,
                          GParamSpec   *pspec)
{
    KcToolBar *self = KC_TOOL_BAR (object);

    switch (prop_id) {
    case PROP_HEADER_LABEL:
        g_value_set_string (value, self->header_label);
        break;
    case PROP_CASE_TYPE:
        g_value_set_enum (value, self->case_type);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_tool_bar_set_property (GObject      *object,
                          uint          prop_id,
                          const GValue *value,
                          GParamSpec   *pspec)
{
    KcToolBar *self = KC_TOOL_BAR (object);

    switch (prop_id) {
    case PROP_HEADER_LABEL:
        self->header_label = g_strdup (g_value_get_string (value));
        break;
    case PROP_CASE_TYPE:
        self->case_type = g_value_get_enum (value);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_tool_bar_constructed (GObject *object)
{
    KcToolBar *self = KC_TOOL_BAR (object);

    gtk_label_set_label (GTK_LABEL (self->case_label), self->header_label);

    G_OBJECT_CLASS (kc_tool_bar_parent_class)->constructed (object);
}

static void
kc_tool_bar_dispose (GObject *object)
{
    KcToolBar *self = KC_TOOL_BAR (object);

    // TODO

    G_OBJECT_CLASS (kc_tool_bar_parent_class)->dispose (object);
}

static void
kc_tool_bar_class_init (KcToolBarClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->get_property = kc_tool_bar_get_property;
    object_class->set_property = kc_tool_bar_set_property;
    object_class->constructed = kc_tool_bar_constructed;
    object_class->dispose = kc_tool_bar_dispose;

    props[PROP_HEADER_LABEL] = 
        g_param_spec_string ("header-label", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS);

    props[PROP_CASE_TYPE] = 
        g_param_spec_enum ("case-type", NULL, NULL,
                           KC_TYPE_CASE_TYPE,
                           KC_CASE_TYPE_SPACE_SEPARATED,
                           G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS);

    g_object_class_install_properties (object_class, N_PROPS, props);
}

static void
case_factory_setup (GtkSignalListItemFactory   *factory,
                    GObject                    *object,
                    gpointer                    user_data)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownButtonContent *content;

    (void) user_data;

    content = kc_dropdown_button_content_new ();
    gtk_list_item_set_child (item, GTK_WIDGET (content));
}

static void
case_factory_bind (GtkSignalListItemFactory    *factory,
                   GObject                     *object,
                   gpointer                     user_data)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownButtonContent *content;
    KcCaseListItem *model;
    const char *name;

    (void) user_data;

    content = KC_DROPDOWN_BUTTON_CONTENT (gtk_list_item_get_child (item));
    model = KC_CASE_LIST_ITEM (gtk_list_item_get_item (item));

    name = kc_case_list_item_get_name (model);

    kc_dropdown_button_content_set_label_text (content, _(name));
}

static void
case_list_factory_setup (GtkSignalListItemFactory   *factory,
                         GObject                    *object,
                         gpointer                    user_data)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownRow *row;

    (void) user_data;

    row = kc_dropdown_row_new ();
    gtk_list_item_set_child (item, GTK_WIDGET (row));
}

static void
case_list_factory_bind (GtkSignalListItemFactory    *factory,
                        GObject                     *object,
                        gpointer                     user_data)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownRow *row;
    KcCaseListItem *model;
    const char *name;
    const char *description;

    (void) user_data;

    row = KC_DROPDOWN_ROW (gtk_list_item_get_child (item));
    model = KC_CASE_LIST_ITEM (gtk_list_item_get_item (item));

    name = kc_case_list_item_get_name (model);
    description = kc_case_list_item_get_description (model);

    kc_dropdown_row_set_title (row, _(name));
    kc_dropdown_row_set_description (row, _(description));
}

static void
kc_tool_bar_init (KcToolBar *self)
{
    g_autoptr (GtkListItemFactory) case_factory;
    g_autoptr (GtkListItemFactory) case_list_factory;
    GListStore *case_listmodel;
    GtkExpression *l10n_case_exp_params[N_L10N_CASE_EXP_PARAMS];
    GtkExpression *l10n_case_exp;
    GtkWidget *case_dropdown;
    GtkWidget *toolbar;

    case_factory = gtk_signal_list_item_factory_new ();
    g_signal_connect (case_factory, "setup", G_CALLBACK (case_factory_setup), NULL);
    g_signal_connect (case_factory, "bind", G_CALLBACK (case_factory_bind), NULL);

    case_list_factory = gtk_signal_list_item_factory_new ();
    g_signal_connect (case_list_factory, "setup", G_CALLBACK (case_list_factory_setup), NULL);
    g_signal_connect (case_list_factory, "bind", G_CALLBACK (case_list_factory_bind), NULL);

    case_listmodel = g_list_store_new (KC_TYPE_CASE_LIST_ITEM);
    g_list_store_append (case_listmodel, kc_case_list_item_new (
        KC_CASE_TYPE_SPACE_SEPARATED,
        N_("Space separated"),
        N_("Each word is separated by a space")
    ));
    g_list_store_append (case_listmodel, kc_case_list_item_new (
        KC_CASE_TYPE_CAMEL,
        "camelCase",
        N_("The first character of compound words is in lowercase")
    ));
    g_list_store_append (case_listmodel, kc_case_list_item_new (
        KC_CASE_TYPE_PASCAL,
        "PascalCase",
        N_("The first character of compound words is in uppercase")
    ));
    g_list_store_append (case_listmodel, kc_case_list_item_new (
        KC_CASE_TYPE_SNAKE,
        "snake_case",
        N_("Each word is separated by an underscore")
    ));
    g_list_store_append (case_listmodel, kc_case_list_item_new (
        KC_CASE_TYPE_KEBAB,
        "kebab-case",
        N_("Each word is separated by a hyphen")
    ));
    g_list_store_append (case_listmodel, kc_case_list_item_new (
        KC_CASE_TYPE_SENTENCE,
        "Sentence case",
        N_("The first character of the first word in the sentence is in uppercase")
    ));

    l10n_case_exp_params[L10N_CASE_EXP_PARAM_STR] = gtk_property_expression_new (KC_TYPE_CASE_LIST_ITEM, NULL, "name");
    l10n_case_exp = gtk_cclosure_expression_new (
        G_TYPE_STRING, NULL, G_N_ELEMENTS (l10n_case_exp_params), l10n_case_exp_params,
        G_CALLBACK (localize_str), NULL, NULL
    );

    case_dropdown = gtk_drop_down_new (G_LIST_MODEL (case_listmodel), l10n_case_exp);
    gtk_drop_down_set_factory (GTK_DROP_DOWN (case_dropdown), case_factory);
    gtk_drop_down_set_list_factory (GTK_DROP_DOWN (case_dropdown), case_list_factory);

    self->case_label = gtk_label_new (NULL);
    gtk_label_set_use_underline (GTK_LABEL (self->case_label), TRUE);
    gtk_label_set_mnemonic_widget (GTK_LABEL (self->case_label), case_dropdown);
    gtk_label_set_wrap (GTK_LABEL (self->case_label), TRUE);
    gtk_label_set_wrap (GTK_LABEL (self->case_label), PANGO_ELLIPSIZE_END);

    self->copy_clipboard_button = gtk_button_new_from_icon_name ("edit-copy");
    gtk_widget_set_tooltip_text (self->copy_clipboard_button, _("Copy to Clipboard"));

    self->toolbar_custom_area = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_valign (self->toolbar_custom_area, GTK_ALIGN_CENTER);
    gtk_widget_set_hexpand (self->toolbar_custom_area, TRUE);

    toolbar = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_valign (toolbar, GTK_ALIGN_CENTER);
    gtk_widget_add_css_class (toolbar, "toolbar");
    gtk_box_append (GTK_BOX (toolbar), self->case_label);
    gtk_box_append (GTK_BOX (toolbar), case_dropdown);
    gtk_box_append (GTK_BOX (toolbar), self->copy_clipboard_button);
    gtk_box_append (GTK_BOX (toolbar), self->toolbar_custom_area);

    adw_bin_set_child (ADW_BIN (self), toolbar);

#if 0
    this.bind_property (
        "case-type",
        case_dropdown, "selected",
        BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
        case_to_selected,
        selected_to_case
    );

    case_dropdown.notify["selected"].connect (() => {
        dropdown_changed ();
    });

    copy_clipboard_button.clicked.connect (() => {
        copy_button_clicked ();
    });
#endif
}

void
kc_tool_bar_append (KcToolBar *self,
                    GtkWidget *widget)
{
    g_return_if_fail (KC_IS_TOOL_BAR (self));
    g_return_if_fail (GTK_IS_WIDGET (widget));

    gtk_box_append (GTK_BOX (self->toolbar_custom_area), widget);
}

KcToolBar *
kc_tool_bar_new (const gchar *header_label)
{
    return g_object_new (KC_TYPE_TOOL_BAR,
                         "header-label", header_label,
                         NULL);
}
