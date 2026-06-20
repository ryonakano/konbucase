/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

G_BEGIN_DECLS

#define KC_TYPE_TEXT_AREA (kc_text_area_get_type ())
G_DECLARE_FINAL_TYPE (KcTextArea, kc_text_area, KC, TEXT_AREA, AdwBin)

extern char *kc_text_area_dup_text (KcTextArea *self);
extern void kc_text_area_set_text (KcTextArea *self, const char *text);
extern void kc_text_area_clear_text (KcTextArea *self);

extern void kc_text_area_grab_focus (KcTextArea *self);

extern KcTextArea *kc_text_area_new (gboolean editable);

G_END_DECLS
