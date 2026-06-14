/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

G_BEGIN_DECLS

#define KC_TYPE_TOOL_BAR (kc_tool_bar_get_type ())
G_DECLARE_FINAL_TYPE (KcToolBar, kc_tool_bar, KC, TOOL_BAR, AdwBin)

extern void kc_tool_bar_append (KcToolBar *self, GtkWidget *widget);
extern KcToolBar *kc_tool_bar_new (const gchar *header_label);

G_END_DECLS
