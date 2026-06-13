/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

G_BEGIN_DECLS

#define KC_TYPE_DROPDOWN_BUTTON_CONTENT (kc_dropdown_button_content_get_type ())
G_DECLARE_FINAL_TYPE (KcDropDownButtonContent, kc_dropdown_button_content, KC, DROPDOWN_BUTTON_CONTENT, AdwBin)

extern KcDropDownButtonContent *kc_dropdown_button_content_new (void);
extern void kc_dropdown_button_content_set_label_text (KcDropDownButtonContent *self, const char *label_text);

G_END_DECLS
