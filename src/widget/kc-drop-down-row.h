/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define KC_TYPE_DROP_DOWN_ROW (kc_drop_down_row_get_type ())
G_DECLARE_FINAL_TYPE (KcDropDownRow, kc_drop_down_row, KC, DROP_DOWN_ROW, GtkBox)

extern const char *kc_drop_down_row_get_title (KcDropDownRow *self);
extern void kc_drop_down_row_set_title (KcDropDownRow *self, const char *title);

extern const char *kc_drop_down_row_get_description (KcDropDownRow *self);
extern void kc_drop_down_row_set_description (KcDropDownRow *self, const char *description);

extern KcDropDownRow *kc_drop_down_row_new (void);

G_END_DECLS
