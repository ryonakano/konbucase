/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-case-list-item.h"

enum {
    PROP_0,

    PROP_CASE_TYPE,
    PROP_NAME,
    PROP_DESCRIPTION,

    N_PROPS
};

static GParamSpec *props[N_PROPS];

/**
 * KcCaseListItem:
 *
 * A list model that has information about a letter case.
 */
struct _KcCaseListItem {
    /*< private >*/
    GObject         parent_instance;

    KcCaseType      case_type;
    char           *name;
    char           *description;
};

G_DEFINE_FINAL_TYPE (KcCaseListItem, kc_case_list_item, G_TYPE_OBJECT)

static void
kc_case_list_item_dispose (GObject *object)
{
    KcCaseListItem *self = KC_CASE_LIST_ITEM (object);

    g_clear_pointer (&self->name, g_free);
    g_clear_pointer (&self->description, g_free);

    G_OBJECT_CLASS (kc_case_list_item_parent_class)->dispose (object);
}

static void
kc_case_list_item_get_property (GObject    *object,
                                guint       prop_id,
                                GValue     *value,
                                GParamSpec *pspec)
{
    KcCaseListItem *self = KC_CASE_LIST_ITEM (object);

    switch (prop_id) {
    case PROP_CASE_TYPE:
        g_value_set_enum (value, self->case_type);
        break;
    case PROP_NAME:
        g_value_set_string (value, self->name);
        break;
    case PROP_DESCRIPTION:
        g_value_set_string (value, self->description);
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_case_list_item_set_property (GObject      *object,
                                guint         prop_id,
                                const GValue *value,
                                GParamSpec   *pspec)
{
    KcCaseListItem *self = KC_CASE_LIST_ITEM (object);

    switch (prop_id) {
    case PROP_CASE_TYPE:
        self->case_type = g_value_get_enum (value);
        break;
    case PROP_NAME:
        g_set_str (&self->name, g_value_get_string (value));
        break;
    case PROP_DESCRIPTION:
        g_set_str (&self->description, g_value_get_string (value));
        break;
    default:
        G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
        break;
    }
}

static void
kc_case_list_item_class_init (KcCaseListItemClass *klass)
{
    GObjectClass *object_class = G_OBJECT_CLASS (klass);

    object_class->dispose = kc_case_list_item_dispose;
    object_class->get_property = kc_case_list_item_get_property;
    object_class->set_property = kc_case_list_item_set_property;

    /**
     * KcCaseListItem:case-type:
     *
     * Type of the letter case.
     */
    props[PROP_CASE_TYPE] =
        g_param_spec_enum ("case-type", NULL, NULL,
                           KC_TYPE_CASE_TYPE,
                           KC_CASE_TYPE_SPACE_SEPARATED,
                           G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    /**
     * KcCaseListItem:name:
     *
     * Display name of the letter case.
     */
    props[PROP_NAME] =
        g_param_spec_string ("name", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    /**
     * KcCaseListItem:description:
     *
     * Description of the letter case.
     */
    props[PROP_DESCRIPTION] =
        g_param_spec_string ("description", NULL, NULL,
                             NULL,
                             G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY | G_PARAM_STATIC_STRINGS | G_PARAM_EXPLICIT_NOTIFY);

    g_object_class_install_properties (object_class, N_PROPS, props);
}

static void
kc_case_list_item_init (KcCaseListItem *self)
{
    self->case_type = KC_CASE_TYPE_SPACE_SEPARATED;
    self->name = NULL;
    self->description = NULL;
}

KcCaseType
kc_case_list_item_get_case_type (KcCaseListItem *self)
{
    g_return_val_if_fail (KC_IS_CASE_LIST_ITEM (self), KC_CASE_TYPE_SPACE_SEPARATED);

    return self->case_type;
}

void
kc_case_list_item_set_case_type (KcCaseListItem *self,
                                 KcCaseType      case_type)
{
    g_return_if_fail (KC_IS_CASE_LIST_ITEM (self));

    if (self->case_type == case_type) {
        return;
    }

    self->case_type = case_type;

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_CASE_TYPE]);
}

const char *
kc_case_list_item_get_name (KcCaseListItem *self)
{
    g_return_val_if_fail (KC_IS_CASE_LIST_ITEM (self), NULL);

    return self->name;
}

void
kc_case_list_item_set_name (KcCaseListItem *self,
                            const char     *name)
{
    g_return_if_fail (KC_IS_CASE_LIST_ITEM (self));

    if (g_strcmp0 (self->name, name) == 0) {
        return;
    }

    g_set_str (&self->name, name);

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_NAME]);
}

const char *
kc_case_list_item_get_description (KcCaseListItem *self)
{
    g_return_val_if_fail (KC_IS_CASE_LIST_ITEM (self), NULL);

    return self->description;
}

void
kc_case_list_item_set_description (KcCaseListItem *self,
                                   const char     *description)
{
    g_return_if_fail (KC_IS_CASE_LIST_ITEM (self));

    if (g_strcmp0 (self->description, description) == 0) {
        return;
    }

    g_set_str (&self->description,description);

    g_object_notify_by_pspec (G_OBJECT (self), props[PROP_DESCRIPTION]);
}

gboolean
kc_case_list_item_equal (KcCaseListItem *self,
                         KcCaseListItem *other)
{
    g_return_val_if_fail (KC_IS_CASE_LIST_ITEM (self), FALSE);
    g_return_val_if_fail (KC_IS_CASE_LIST_ITEM (other), FALSE);

    // Case type won't be duplicated, so it's enough to compare only with it
    return self->case_type == other->case_type;
}

/**
 * kc_case_list_item_new:
 * @case_type: type of the letter case
 * @name: (transfer none): display name of the letter case
 * @description: (transfer none): description of the letter case
 *
 * Creates a new `KcCaseListItem`.
 *
 * Returns: (transfer full): a new `KcCaseListItem`
 */
KcCaseListItem *
kc_case_list_item_new (KcCaseType  case_type,
                       const char *name,
                       const char *description)
{
    return g_object_new (KC_TYPE_CASE_LIST_ITEM,
                         "case-type", case_type,
                         "name", name,
                         "description", description,
                         NULL);
}
