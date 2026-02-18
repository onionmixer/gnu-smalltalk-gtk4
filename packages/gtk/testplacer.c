/***********************************************************************
 *
 *  Example of using the placer geometry manager
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/

#include <gtk/gtk.h>
#include "placer.h"
#include "placer.c"

static GMainLoop *main_loop;

gint rel_width = 5461;
gint rel_height = 8191;

void move_button (GtkWidget *widget,
                  GtkWidget *placer)
{
  rel_width = 5461 + 8192 - rel_width;
  rel_height = 8192 + 10922 - rel_height;
  gtk_placer_resize_rel (GTK_PLACER (placer), widget, rel_width, rel_height);
}

static void
on_destroy (GtkWidget *widget, gpointer data)
{
  g_main_loop_quit (main_loop);
}

int main (int   argc,
          char *argv[])
{
  /* GtkWidget is the storage type for widgets */
  GtkWidget *window;
  GtkWidget *placer;
  GtkWidget *button;
  gint i;

  const int rel_x[4] = { 0, 8192, 16384, 24576 };
  const int rel_y[3] = { 0, 10922, 21844 };

  /* GTK4: gtk_init() takes no arguments. */
  gtk_init ();

  /* Create a new window */
  window = gtk_window_new ();
  gtk_window_set_title (GTK_WINDOW (window), "Placer Container");

  /* Here we connect the "destroy" event to a signal handler */
  g_signal_connect (G_OBJECT (window), "destroy",
		    G_CALLBACK (on_destroy), NULL);

  /* GTK4: border width via margins on child widget. */
  /* Create a Placer Container */
  placer = gtk_placer_new ();
  gtk_widget_set_margin_start (placer, 5);
  gtk_widget_set_margin_end (placer, 5);
  gtk_widget_set_margin_top (placer, 5);
  gtk_widget_set_margin_bottom (placer, 5);
  gtk_window_set_child (GTK_WINDOW (window), placer);

  for (i = 0 ; i <= 11 ; i++) {
    /* Creates a new button with the label "Press me" */
    button = gtk_button_new_with_label ("Press me");

    /* When the button receives the "clicked" signal, it will call the
     * function move_button() passing it the Fixed Container as its
     * argument. */
    g_signal_connect (G_OBJECT (button), "clicked",
		      G_CALLBACK (move_button), (gpointer) placer);

    /* This packs the button into the placer containers window. */
    gtk_placer_put (GTK_PLACER (placer), button,
		    5, 2, -10, -4,
		    rel_x[i % 4], rel_y[i / 4],
		    rel_width, rel_height);
  }

  /* Display the window */
  gtk_widget_set_visible (window, TRUE);

  /* Enter the event loop */
  main_loop = g_main_loop_new (NULL, FALSE);
  g_main_loop_run (main_loop);
  g_main_loop_unref (main_loop);

  return 0;
}
