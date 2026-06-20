/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

#include "kc-enums.h"
#include "kc-types.h"

G_BEGIN_DECLS

#define KC_TYPE_TOOL_BAR (kc_tool_bar_get_type ())
G_DECLARE_FINAL_TYPE (KcToolBar, kc_tool_bar, KC, TOOL_BAR, AdwBin)

extern KcCaseType kc_tool_bar_get_case_type (KcToolBar *self);
extern void kc_tool_bar_set_case_type (KcToolBar *self, KcCaseType case_type);

extern GtkWidget *kc_tool_bar_get_copy_clipboard_button (KcToolBar *self);

extern void kc_tool_bar_append (KcToolBar *self, GtkWidget *widget);

extern KcToolBar *kc_tool_bar_new (const char *header_label);

G_END_DECLS
