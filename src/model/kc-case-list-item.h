/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <glib-object.h>

#include "kc-enums.h"
#include "kc-types.h"

G_BEGIN_DECLS

#define KC_TYPE_CASE_LIST_ITEM (kc_case_list_item_get_type ())
G_DECLARE_FINAL_TYPE (KcCaseListItem, kc_case_list_item, KC, CASE_LIST_ITEM, GObject)

extern KcCaseType kc_case_list_item_get_case_type (KcCaseListItem *self);
extern void kc_case_list_item_set_case_type (KcCaseListItem *self, KcCaseType case_type);

extern const gchar * kc_case_list_item_get_name (KcCaseListItem *self);
extern void kc_case_list_item_set_name (KcCaseListItem *self, const gchar *name);

extern const gchar * kc_case_list_item_get_description (KcCaseListItem *self);
extern void kc_case_list_item_set_description (KcCaseListItem *self, const gchar *description);

extern gboolean kc_case_list_item_equals (KcCaseListItem *a, KcCaseListItem *b);
extern KcCaseListItem *kc_case_list_item_new (KcCaseType case_type, const gchar *name, const gchar *description);

G_END_DECLS
