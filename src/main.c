/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "kc-types.h"
#include "kc-enums.h"

#include "kc-case-list-item.h"

int
main (int   argc,
      char *argv[])
{
    g_autoptr(KcCaseListItem) item;
    KcCaseType case_type;
    gchar *name;
    gchar *description;

    item = kc_case_list_item_new (KC_CASE_TYPE_SPACE_SEPARATED, "name", "desc");

    g_object_get (item,
                  "case-type", &case_type,
                  "name", &name,
                  "description", &description,
                  NULL);

    g_print ("%d, %s, %s\n", case_type, name, description);

    g_object_set (item,
                  "case-type", KC_CASE_TYPE_SNAKE,
                  "name", g_strdup ("eman"),
                  "description", g_strdup ("csed"),
                  NULL);

    g_object_get (item,
                  "case-type", &case_type,
                  "name", &name,
                  "description", &description,
                  NULL);

    g_print ("%d, %s, %s\n", case_type, name, description);

    return 0;
}
