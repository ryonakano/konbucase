/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define KC_TYPE_MAIN_VIEW (kc_main_view_get_type ())
G_DECLARE_FINAL_TYPE (KcMainView, kc_main_view, KC, MAIN_VIEW, GtkBox)

extern KcMainView *kc_main_view_new (void);

G_END_DECLS
