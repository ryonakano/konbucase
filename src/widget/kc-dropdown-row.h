/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define KC_TYPE_DROPDOWN_ROW (kc_dropdown_row_get_type ())
G_DECLARE_FINAL_TYPE (KcDropDownRow, kc_dropdown_row, KC, DROPDOWN_ROW, GtkBox)

extern void kc_dropdown_row_set_title (KcDropDownRow *self, const char *str);
extern const char *kc_dropdown_row_get_title (KcDropDownRow *self);

extern void kc_dropdown_row_set_description (KcDropDownRow *self, const char *str);
extern const char *kc_dropdown_row_get_description (KcDropDownRow *self);

extern KcDropDownRow *kc_dropdown_row_new (void);

G_END_DECLS
