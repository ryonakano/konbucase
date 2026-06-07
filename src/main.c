/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2020-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include "config.h"

#include <locale.h>

#include <glib/gi18n.h>

#include "kc-application.h"
#include "kc-enums.h"
#include "kc-types.h"

int
main (int   argc,
      char *argv[])
{
    g_autoptr(KcApplication) app = NULL;
    int ret;

    setlocale (LC_ALL, "");
    bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
    bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
    textdomain (GETTEXT_PACKAGE);

    app = kc_application_new ();
    ret = g_application_run (G_APPLICATION (app), argc, argv);

    return ret;
}
