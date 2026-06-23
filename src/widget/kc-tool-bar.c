/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-tool-bar.h"

#include <glib/gi18n.h>
#include <gtk/gtk.h>
#include <pango/pango.h>

#include "kc-case-list-item.h"
#include "kc-drop-down-button-content.h"
#include "kc-drop-down-row.h"

/**
 * A widget that contains controls for text input/output.
 *
 * <picture>
 *   <img src="example_toolbar.png" alt="example image of ToolBar">
 * </picture>
 */

enum {
    L10N_CASE_EXP_PARAM_STR,

    N_L10N_CASE_EXP_PARAMS
};

enum {
    SIGNAL_DROP_DOWN_CHANGED,
    SIGNAL_COPY_BUTTON_CLICKED,

    N_SIGNALS
};

static guint signals[N_SIGNALS];

enum {
    PROP_0,

    PROP_HEADER_TEXT,
    PROP_CASE_TYPE,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

struct _KcToolBar {
    AdwBin          parent_instance;

    KcCaseType      case_type;

    GtkWidget      *header_label;
    GtkWidget      *copy_button;
    GtkWidget      *toolbar_custom_area;
};

G_DEFINE_FINAL_TYPE (KcToolBar, kc_tool_bar, ADW_TYPE_BIN)

static char *
localize_str (const char *str)
{
    return g_strdup (_(str));
}

static void
case_factory_setup (GtkSignalListItemFactory *factory,
                    GObject                  *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownButtonContent *content;

    content = kc_drop_down_button_content_new ();
    gtk_list_item_set_child (item, GTK_WIDGET (content));
}

static void
case_factory_bind (GtkSignalListItemFactory *factory,
                   GObject                  *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownButtonContent *content;
    KcCaseListItem *model;
    const char *name;

    content = KC_DROP_DOWN_BUTTON_CONTENT (gtk_list_item_get_child (item));
    model = KC_CASE_LIST_ITEM (gtk_list_item_get_item (item));

    name = kc_case_list_item_get_name (model);

    kc_drop_down_button_content_set_label_text (content, _(name));
}

static void
case_list_factory_setup (GtkSignalListItemFactory *factory,
                         GObject                  *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownRow *row;

    row = kc_drop_down_row_new ();
    gtk_list_item_set_child (item, GTK_WIDGET (row));
}

static void
case_list_factory_bind (GtkSignalListItemFactory *factory,
                        GObject                  *object)
{
    GtkListItem *item = GTK_LIST_ITEM (object);
    KcDropDownRow *row;
    KcCaseListItem *model;
    const char *name;
    const char *description;

    row = KC_DROP_DOWN_ROW (gtk_list_item_get_child (item));
    model = KC_CASE_LIST_ITEM (gtk_list_item_get_item (item));

    name = kc_case_list_item_get_name (model);
    description = kc_case_list_item_get_description (model);

    kc_drop_down_row_set_title (row, _(name));
    kc_drop_down_row_set_description (row, _(description));
}

static gboolean
case_type_to_selected (GBinding     *binding,
                       const GValue *case_type,
                       GValue       *selected,
                       gpointer      user_data)
{
    GListStore *case_liststore = G_LIST_STORE (user_data);
    KcCaseType _case_type;
    g_autoptr(KcCaseListItem) lookup_item = NULL;
    guint pos;
    gboolean found;

    _case_type = g_value_get_enum (case_type);
    // Find with case type
    lookup_item = kc_case_list_item_new (_case_type, "", "");

    found = g_list_store_find_with_equal_func (case_liststore,
                                               lookup_item,
                                               (GEqualFunc) kc_case_list_item_equal,
                                               &pos);
    if (G_UNLIKELY (!found)) {
        return FALSE;
    }

    g_value_set_uint (selected, pos);

    return TRUE;
}

static gboolean
selected_to_case_type (GBinding     *binding,
                       const GValue *selected,
                       GValue       *case_type,
                       gpointer      user_data)
{
    GListStore *case_liststore = G_LIST_STORE (user_data);
    guint pos;
    g_autoptr(KcCaseListItem) selected_item = NULL;
    KcCaseType _case_type;

    pos = g_value_get_uint (selected);
    if (G_UNLIKELY (pos == GTK_INVALID_LIST_POSITION)) {
        // No item is selected
        return FALSE;
    }

    selected_item = KC_CASE_LIST_ITEM (g_list_model_get_item (G_LIST_MODEL (case_liststore), pos));
    if (G_UNLIKELY (!selected_item)) {
        return FALSE;
    }

    _case_type = kc_case_list_item_get_case_type (selected_item);
    g_value_set_enum (case_type, _case_type);

    return true;
}

static void
emit_drop_down_changed (KcToolBar *self)
{
    g_signal_emit (self, signals[SIGNAL_DROP_DOWN_CHANGED], 0);
}

static void
emit_copy_button_clicked (KcToolBar *self)
{
    g_signal_emit (self, signals[SIGNAL_COPY_BUTTON_CLICKED], 0);
}

static void
kc_tool_bar_get_property (GObject    *object,
                          uint        prop_id,
                          GValue     *value,
                          GParamSpec *pspec)
{
    KcToolBar *self = KC_TOOL_BAR (object);

    switch (prop_id) {
    case PROP_HEADER_TEXT:
        g_value_set_string (value, kc_tool_bar_get_header_text (self));
        break;
    case PROP_CASE_TYPE:
        g_value_set_enum (value, kc_tool_bar_get_case_type (self));
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
    case PROP_HEADER_TEXT:
        kc_tool_bar_set_header_text (self, g_value_get_string (value));
        break;
    case PROP_CASE_TYPE:
        kc_tool_bar_set_case_type (self, g_value_get_enum (value));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_tool_bar_dispose (GObject *object)
{
    KcToolBar *self = KC_TOOL_BAR (object);

    adw_bin_set_child (ADW_BIN (self), NULL);

    G_OBJECT_CLASS (kc_tool_bar_parent_class)->dispose (object);
}

static void
kc_tool_bar_class_init (KcToolBarClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->get_property = kc_tool_bar_get_property;
    object_class->set_property = kc_tool_bar_set_property;
    object_class->dispose = kc_tool_bar_dispose;

    /**
     * KcToolBar::drop-down-changed:
     *
     * Emitted when selection of the #GtkDropDown that selects type of letter case is changed.
     */
    signals[SIGNAL_DROP_DOWN_CHANGED] =
        g_signal_new ("drop-down-changed",
                      G_TYPE_FROM_CLASS (klass),
                      G_SIGNAL_RUN_LAST,
                      0,
                      NULL,
                      NULL,
                      NULL,
                      G_TYPE_NONE,
                      0);

    /**
     * KcToolBar::copy-button-clicked:
     *
     * Emitted when the #GtkButton to copy text is clicked.
     */
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

    /**
     * KcToolBar:header-text:
     *
     * Text to show alongside the #GtkDropDown that selects type of letter case.
     */
    props[PROP_HEADER_TEXT] =
        g_param_spec_string ("header-text", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    /**
     * KcToolBar:case-type:
     *
     * Type of letter case that currently preferred.
     */
    props[PROP_CASE_TYPE] =
        g_param_spec_enum ("case-type", NULL, NULL,
                           KC_TYPE_CASE_TYPE,
                           KC_CASE_TYPE_SPACE_SEPARATED,
                           G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    g_object_class_install_properties (object_class, N_PROPS, props);
}

static void
kc_tool_bar_init (KcToolBar *self)
{
    g_autoptr(GtkListItemFactory) case_factory = NULL;
    g_autoptr(GtkListItemFactory) case_list_factory = NULL;
    KcCaseListItem *case_listitems[N_KC_CASE_TYPE];
    GListStore *case_liststore;
    int i;
    GtkExpression *l10n_case_exp_params[N_L10N_CASE_EXP_PARAMS];
    GtkExpression *l10n_case_exp;
    GtkWidget *case_drop_down;
    GtkWidget *toolbar;

    self->case_type = KC_CASE_TYPE_SPACE_SEPARATED;

    case_factory = gtk_signal_list_item_factory_new ();
    g_signal_connect (case_factory, "setup", G_CALLBACK (case_factory_setup), NULL);
    g_signal_connect (case_factory, "bind", G_CALLBACK (case_factory_bind), NULL);

    case_list_factory = gtk_signal_list_item_factory_new ();
    g_signal_connect (case_list_factory, "setup", G_CALLBACK (case_list_factory_setup), NULL);
    g_signal_connect (case_list_factory, "bind", G_CALLBACK (case_list_factory_bind), NULL);

    case_listitems[KC_CASE_TYPE_SPACE_SEPARATED] =
        kc_case_list_item_new (KC_CASE_TYPE_SPACE_SEPARATED,
                               N_("Space separated"),
                               N_("Each word is separated by a space"));
    case_listitems[KC_CASE_TYPE_CAMEL] =
        kc_case_list_item_new (KC_CASE_TYPE_CAMEL,
                               "camelCase",
                               N_("The first character of compound words is in lowercase"));
    case_listitems[KC_CASE_TYPE_PASCAL] =
        kc_case_list_item_new (KC_CASE_TYPE_PASCAL,
                               "PascalCase",
                               N_("The first character of compound words is in uppercase"));
    case_listitems[KC_CASE_TYPE_SNAKE] =
        kc_case_list_item_new (KC_CASE_TYPE_SNAKE,
                               "snake_case",
                               N_("Each word is separated by an underscore"));
    case_listitems[KC_CASE_TYPE_KEBAB] =
        kc_case_list_item_new (KC_CASE_TYPE_KEBAB,
                               "kebab-case",
                               N_("Each word is separated by a hyphen"));
    case_listitems[KC_CASE_TYPE_SENTENCE] =
        kc_case_list_item_new (KC_CASE_TYPE_SENTENCE,
                               "Sentence case",
                               N_("The first character of the first word in the sentence is in uppercase"));

    case_liststore = g_list_store_new (KC_TYPE_CASE_LIST_ITEM);
    g_list_store_splice (case_liststore, 0, 0, (gpointer *) &case_listitems, G_N_ELEMENTS (case_listitems));
    for (i = 0; i < G_N_ELEMENTS (case_listitems); i++) {
        g_object_unref (case_listitems[i]);
    }

    l10n_case_exp_params[L10N_CASE_EXP_PARAM_STR] = gtk_property_expression_new (KC_TYPE_CASE_LIST_ITEM, NULL, "name");
    l10n_case_exp = gtk_cclosure_expression_new (
        G_TYPE_STRING, NULL, G_N_ELEMENTS (l10n_case_exp_params), l10n_case_exp_params,
        G_CALLBACK (localize_str), NULL, NULL
    );

    case_drop_down = gtk_drop_down_new (G_LIST_MODEL (case_liststore), l10n_case_exp);
    gtk_drop_down_set_factory (GTK_DROP_DOWN (case_drop_down), case_factory);
    gtk_drop_down_set_list_factory (GTK_DROP_DOWN (case_drop_down), case_list_factory);

    self->header_label = gtk_label_new (NULL);
    gtk_label_set_use_underline (GTK_LABEL (self->header_label), TRUE);
    gtk_label_set_mnemonic_widget (GTK_LABEL (self->header_label), case_drop_down);
    gtk_label_set_wrap (GTK_LABEL (self->header_label), TRUE);
    gtk_label_set_wrap (GTK_LABEL (self->header_label), PANGO_ELLIPSIZE_END);

    self->copy_button = gtk_button_new_from_icon_name ("edit-copy");
    gtk_widget_set_tooltip_text (self->copy_button, _("Copy to Clipboard"));

    self->toolbar_custom_area = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_valign (self->toolbar_custom_area, GTK_ALIGN_CENTER);
    gtk_widget_set_hexpand (self->toolbar_custom_area, TRUE);

    toolbar = gtk_box_new (GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_valign (toolbar, GTK_ALIGN_CENTER);
    gtk_widget_add_css_class (toolbar, "toolbar");
    gtk_box_append (GTK_BOX (toolbar), self->header_label);
    gtk_box_append (GTK_BOX (toolbar), case_drop_down);
    gtk_box_append (GTK_BOX (toolbar), self->copy_button);
    gtk_box_append (GTK_BOX (toolbar), self->toolbar_custom_area);

    adw_bin_set_child (ADW_BIN (self), toolbar);

    g_object_bind_property_full (G_OBJECT (self), "case-type",
                                 G_OBJECT (case_drop_down), "selected",
                                 G_BINDING_BIDIRECTIONAL | G_BINDING_SYNC_CREATE,
                                 case_type_to_selected,
                                 selected_to_case_type,
                                 case_liststore,
                                 NULL);

    g_signal_connect_swapped (case_drop_down, "notify::selected", G_CALLBACK (emit_drop_down_changed), self);

    g_signal_connect_swapped (self->copy_button, "clicked", G_CALLBACK (emit_copy_button_clicked), self);
}

/**
 * kc_tool_bar_get_header_text:
 * @self: a `KcToolBar`
 *
 * Gets text to show alongside the #GtkDropDown that selects type of letter case for @self.
 *
 * Returns: (nullable) (transfer none): text to show alongside the #GtkDropDown that selects type of letter case
 */
const char *
kc_tool_bar_get_header_text (KcToolBar *self)
{
    g_return_val_if_fail (KC_IS_TOOL_BAR (self), NULL);

    return gtk_label_get_label (GTK_LABEL (self->header_label));
}

/**
 * kc_tool_bar_set_header_text:
 * @self: a `KcToolBar`
 * @text: (nullable) (transfer none): text to show alongside the #GtkDropDown that selects type of letter case
 *
 * Sets text to show alongside the #GtkDropDown that selects type of letter case for @self.
 */
void
kc_tool_bar_set_header_text (KcToolBar  *self,
                             const char *text)
{
    g_return_if_fail (KC_IS_TOOL_BAR (self));

    gtk_label_set_label (GTK_LABEL (self->header_label), text);

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_HEADER_TEXT]);
}

/**
 * kc_tool_bar_get_case_type:
 * @self: a `KcToolBar`
 *
 * Gets type of letter case that currently preferred for @self.
 *
 * Returns: type of letter case that currently preferred
 */
KcCaseType
kc_tool_bar_get_case_type (KcToolBar *self)
{
    g_return_val_if_fail (KC_IS_TOOL_BAR (self), KC_CASE_TYPE_SPACE_SEPARATED);

    return self->case_type;
}

/**
 * kc_tool_bar_set_case_type:
 * @self: a `KcToolBar`
 * @case_type: type of letter case that currently preferred
 *
 * Sets type of letter case that currently preferred for @self.
 */
void
kc_tool_bar_set_case_type (KcToolBar  *self,
                           KcCaseType  case_type)
{
    g_return_if_fail (KC_IS_TOOL_BAR (self));

    if (self->case_type == case_type) {
        return;
    }

    self->case_type = case_type;

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CASE_TYPE]);
}

/**
 * kc_tool_bar_get_copy_button:
 * @self: a `KcToolBar`
 *
 * Gets the #GtkButton to copy text for @self.
 *
 * Returns: (transfer none): the #GtkButton to copy text
 */
GtkWidget *
kc_tool_bar_get_copy_button (KcToolBar *self)
{
    g_return_val_if_fail (KC_IS_TOOL_BAR (self), NULL);

    return self->copy_button;
}

/**
 * kc_tool_bar_append:
 * @self: a `KcToolBar`
 * @widget: (transfer floating): the widget to append
 *
 * Adds an additional widget at the end.
 */
void
kc_tool_bar_append (KcToolBar *self,
                    GtkWidget *widget)
{
    g_return_if_fail (KC_IS_TOOL_BAR (self));
    g_return_if_fail (GTK_IS_WIDGET (widget));

    gtk_box_append (GTK_BOX (self->toolbar_custom_area), widget);
}

/**
 * kc_tool_bar_new:
 * @header_text: text to show alongside the #GtkDropDown that selects type of letter case
 *
 * Creates a new `KcToolBar`.
 *
 * Returns: (transfer full): the newly created `KcToolBar`
 */
KcToolBar *
kc_tool_bar_new (const char *header_text)
{
    return g_object_new (KC_TYPE_TOOL_BAR,
                         "header-text", header_text,
                         NULL);
}
