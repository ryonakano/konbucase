/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <chcase/chcase.h>

#include "kc-enums.h"
#include "kc-types.h"

extern KcCaseType kc_case_convert_to_case_type (ChCaseCase chcase_case);
extern ChCaseCase kc_case_convert_to_chcase_case (KcCaseType case_type);
extern char *kc_case_convert_do_convert (ChCaseConverter *converter, KcCaseType input_case, const char *input_text, KcCaseType output_case);
