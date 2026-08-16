/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <adwaita.h>

extern AdwColorScheme kc_convert_to_adw_scheme (const char *str_scheme);
extern const char *kc_convert_to_str_scheme (AdwColorScheme adw_scheme);
