/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

G_BEGIN_DECLS

#define KC_TYPE_APPLICATION         (kc_application_get_type ())
G_DECLARE_FINAL_TYPE (KcApplication, kc_application, KC, APPLICATION, AdwApplication)

extern KcApplication *kc_application_new (void);

G_END_DECLS
