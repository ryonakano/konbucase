/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

#include "kc-application.h"

G_BEGIN_DECLS

#define KC_TYPE_MAIN_WINDOW (kc_main_window_get_type ())
G_DECLARE_FINAL_TYPE (KcMainWindow, kc_main_window, KC, MAIN_WINDOW, AdwApplicationWindow)

extern KcMainWindow *kc_main_window_new (KcApplication *app);

G_END_DECLS
