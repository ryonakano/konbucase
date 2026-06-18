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

enum {
    L10N_CASE_EXP_PARAM_STR,

    N_L10N_CASE_EXP_PARAMS
};

enum {
    SIGNAL_DROPDOWN_CHANGED,
    SIGNAL_COPY_BUTTON_CLICKED,

    N_SIGNALS
};

static guint signals[N_SIGNALS];

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
    GtkWidget      *copy_button;

    GtkWidget      *toolbar_custom_area;
};

G_DEFINE_FINAL_TYPE (KcToolBar, kc_tool_bar, ADW_TYPE_BIN)

static gchar *
localize_str (const gchar *str)
{
    return g_strdup (_(str));
}

static void
case_factory_setup (GtkSignalListItemFactory   *factory,
                    GObject                    *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownButtonContent *content;

    (void) factory;

    content = kc_dropdown_button_content_new ();
    gtk_list_item_set_child (item, GTK_WIDGET (content));
}

static void
case_factory_bind (GtkSignalListItemFactory    *factory,
                   GObject                     *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownButtonContent *content;
    KcCaseListItem *model;
    const char *name;

    (void) factory;

    content = KC_DROPDOWN_BUTTON_CONTENT (gtk_list_item_get_child (item));
    model = KC_CASE_LIST_ITEM (gtk_list_item_get_item (item));

    name = kc_case_list_item_get_name (model);

    kc_dropdown_button_content_set_label_text (content, _(name));
}

static void
case_list_factory_setup (GtkSignalListItemFactory   *factory,
                         GObject                    *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownRow *row;

    (void) factory;

    row = kc_dropdown_row_new ();
    gtk_list_item_set_child (item, GTK_WIDGET (row));
}

static void
case_list_factory_bind (GtkSignalListItemFactory    *factory,
                        GObject                     *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownRow *row;
    KcCaseListItem *model;
    const char *name;
    const char *description;

    (void) factory;

    row = KC_DROPDOWN_ROW (gtk_list_item_get_child (item));
    model = KC_CASE_LIST_ITEM (gtk_list_item_get_item (item));

    name = kc_case_list_item_get_name (model);
    description = kc_case_list_item_get_description (model);

    kc_dropdown_row_set_title (row, _(name));
    kc_dropdown_row_set_description (row, _(description));
}

static gboolean
case_type_to_selected (GBinding        *binding,
                       const GValue    *case_type,
                       GValue          *selected,
                       gpointer         user_data)
{
    GListStore *case_listmodel = G_LIST_STORE (user_data);
    KcCaseType _case_type;
    guint pos;
    gboolean found;

    _case_type = g_value_get_enum (case_type);

    found = g_list_store_find_with_equal_func (case_listmodel,
                                               // Find with case type
                                               kc_case_list_item_new (_case_type, "", ""),
                                               (GEqualFunc) kc_case_list_item_equals,
                                               &pos);
    if (!found) {
        return FALSE;
    }

    g_value_set_uint (selected, pos);

    return TRUE;
}

static gboolean
selected_to_case_type (GBinding        *binding,
                       const GValue    *selected,
                       GValue          *case_type,
                       gpointer         user_data)
{
    GListStore *case_listmodel = G_LIST_STORE (user_data);
    guint pos;
    KcCaseListItem *selected_item;
    KcCaseType _case_type;

    pos = g_value_get_uint (selected);

    if (pos == GTK_INVALID_LIST_POSITION) {
        // No item is selected
        return FALSE;
    }

    selected_item = KC_CASE_LIST_ITEM (g_list_model_get_item (G_LIST_MODEL (case_listmodel), pos));
    if (!selected_item) {
        return FALSE;
    }

    _case_type = kc_case_list_item_get_case_type (selected_item);
    g_value_set_enum (case_type, _case_type);

    return true;
}

static void
notify_dropdown_changed (KcToolBar *self)
{
    g_signal_emit (self, signals[SIGNAL_DROPDOWN_CHANGED], 0);
}

static void
emit_copy_button_clicked (KcToolBar *self)
{
    g_signal_emit (self, signals[SIGNAL_COPY_BUTTON_CLICKED], 0);
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
        g_set_str (&(self->header_label), g_value_get_string (value));
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

    adw_bin_set_child (ADW_BIN (self), NULL);

    g_clear_pointer (&(self->header_label), g_free);

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

    signals[SIGNAL_DROPDOWN_CHANGED] =
        g_signal_new ("dropdown-changed",
                      G_TYPE_FROM_CLASS (klass),
                      G_SIGNAL_RUN_LAST,
                      0,
                      NULL,
                      NULL,
                      NULL,
                      G_TYPE_NONE,
                      0);

    signals[SIGNAL_COPY_BUTTON_CLICKED] =
        g_signal_new ("copy-button-clicked",
                      G_TYPE_FROM_CLASS (klass),
                      G_SIGNAL_RUN_LAST,
                      0,
                      NULL,
                      NULL,
                      NULL,
                      G_TYPE_NONE,
                      0);

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
kc_tool_bar_init (KcToolBar *self)
{
    g_autoptr (GtkListItemFactory) case_factory = NULL;
    g_autoptr (GtkListItemFactory) case_list_factory = NULL;
    GListStore *case_listmodel;
    GtkExpression *l10n_case_exp_params[N_L10N_CASE_EXP_PARAMS];
    GtkExpression *l10n_case_exp;
    GtkWidget *case_dropdown;
    GtkWidget *toolbar;

    self->header_label = NULL;
    self->case_type = KC_CASE_TYPE_SPACE_SEPARATED;

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

    self->copy_button = gtk_button_new_from_icon_name ("edit-copy");
    gtk_widget_set_tooltip_text (self->copy_button, _("Copy to Clipboard"));

    self->toolbar_custom_area = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_valign (self->toolbar_custom_area, GTK_ALIGN_CENTER);
    gtk_widget_set_hexpand (self->toolbar_custom_area, TRUE);

    toolbar = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_valign (toolbar, GTK_ALIGN_CENTER);
    gtk_widget_add_css_class (toolbar, "toolbar");
    gtk_box_append (GTK_BOX (toolbar), self->case_label);
    gtk_box_append (GTK_BOX (toolbar), case_dropdown);
    gtk_box_append (GTK_BOX (toolbar), self->copy_button);
    gtk_box_append (GTK_BOX (toolbar), self->toolbar_custom_area);

    adw_bin_set_child (ADW_BIN (self), toolbar);

    g_object_bind_property_full (G_OBJECT (self), "case-type",
                                 G_OBJECT (case_dropdown), "selected",
                                 G_BINDING_BIDIRECTIONAL | G_BINDING_SYNC_CREATE,
                                 case_type_to_selected,
                                 selected_to_case_type,
                                 g_object_ref (case_listmodel),
                                 g_object_unref);

    g_signal_connect_swapped (case_dropdown, "notify::selected", G_CALLBACK (notify_dropdown_changed), self);
    g_signal_connect_swapped (self->copy_button, "clicked", G_CALLBACK (emit_copy_button_clicked), self);
}

KcCaseType
kc_tool_bar_get_case_type (KcToolBar *self)
{
    g_return_val_if_fail (KC_IS_TOOL_BAR (self), KC_CASE_TYPE_SPACE_SEPARATED);

    return self->case_type;
}

void
kc_tool_bar_set_case_type (KcToolBar   *self,
                           KcCaseType   case_type)
{
    g_return_if_fail (KC_IS_TOOL_BAR (self));

    if (self->case_type == case_type) {
        return;
    }

    self->case_type = case_type;

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CASE_TYPE]);
}

GtkWidget *
kc_tool_bar_get_copy_clipboard_button (KcToolBar *self)
{
    g_return_val_if_fail (KC_IS_TOOL_BAR (self), NULL);

    return self->copy_button;
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
                         "header-label", g_strdup (header_label),
                         NULL);
}
