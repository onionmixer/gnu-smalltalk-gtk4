/***********************************************************************
 *
 *  GTK wrappers for GNU Smalltalk
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2003, 2006, 2008, 2009 Free Software Foundation, Inc.
 * Written by Paolo Bonzini, Norman Jordan, Mike S. Anderson.
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

#include "config.h"
#include "gstpub.h"
#include "gst-gobject.h"

#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <gtk/gtk.h>
#include <glib-object.h>
#include <glib.h>
#include <pango/pango.h>

#include <gobject/gvaluecollector.h>

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

#include "placer.h"

static VMProxy *_gtk_vm_proxy;

/* GtkAccelGroup removed in GTK4 (use GtkShortcutController).
   GtkContainer removed in GTK4 (child properties replaced by
   widget-specific APIs). */

/* Wrappers for accessor functions.
   Updated for GTK4 compatibility.  */

static GdkSurface *
widget_get_surface (GtkWidget *widget)
{
  GtkNative *native = gtk_widget_get_native (widget);
  if (native)
    return gtk_native_get_surface (native);
  return NULL;
}

static int
widget_get_state (GtkWidget *widget)
{
  return (int) gtk_widget_get_state_flags (widget);
}

static int
widget_get_flags (GtkWidget *widget)
{
  int flags = 0;
  if (gtk_widget_get_visible (widget)) flags |= (1 << 0);
  if (gtk_widget_get_mapped (widget)) flags |= (1 << 1);
  if (gtk_widget_get_realized (widget)) flags |= (1 << 2);
  if (gtk_widget_get_sensitive (widget)) flags |= (1 << 3);
  if (gtk_widget_get_focusable (widget)) flags |= (1 << 4);
  if (gtk_widget_has_focus (widget)) flags |= (1 << 5);
  /* bit 6 (has_default) removed in GTK4 */
  /* bit 7 (no_window/has_window) removed in GTK4 */
  return flags;
}

static void
widget_set_flags (GtkWidget *widget, int flags)
{
  if (flags & (1 << 0)) gtk_widget_set_visible (widget, TRUE);
  if (flags & (1 << 3)) gtk_widget_set_sensitive (widget, TRUE);
  if (flags & (1 << 4)) gtk_widget_set_focusable (widget, TRUE);
}

static void
widget_unset_flags (GtkWidget *widget, int flags)
{
  if (flags & (1 << 0)) gtk_widget_set_visible (widget, FALSE);
  if (flags & (1 << 3)) gtk_widget_set_sensitive (widget, FALSE);
  if (flags & (1 << 4)) gtk_widget_set_focusable (widget, FALSE);
}


static GtkAllocation *
widget_get_allocation (GtkWidget *wgt)
{
  /* GTK4: gtk_widget_get_allocation() removed.
     Use width/height; x/y are 0 in widget's own coordinate space. */
  static GtkAllocation alloc;
  alloc.x = 0;
  alloc.y = 0;
  alloc.width = gtk_widget_get_width (wgt);
  alloc.height = gtk_widget_get_height (wgt);
  return &alloc;
}

G_GNUC_BEGIN_IGNORE_DEPRECATIONS
static GtkWidget *
dialog_get_vbox (GtkDialog *dlg)
{
  return gtk_dialog_get_content_area (dlg);
}
G_GNUC_END_IGNORE_DEPRECATIONS

static int
scrolled_window_get_hscrollbar_visible (GtkScrolledWindow *swnd)
{
  GtkPolicyType hpolicy, vpolicy;
  gtk_scrolled_window_get_policy (swnd, &hpolicy, &vpolicy);
  return (hpolicy != GTK_POLICY_NEVER);
}

static int
scrolled_window_get_vscrollbar_visible (GtkScrolledWindow *swnd)
{
  GtkPolicyType hpolicy, vpolicy;
  gtk_scrolled_window_get_policy (swnd, &hpolicy, &vpolicy);
  return (vpolicy != GTK_POLICY_NEVER);
}

static int
adjustment_get_lower (GtkAdjustment *adj)
{
  return (int) gtk_adjustment_get_lower (adj);
}

static int
adjustment_get_upper (GtkAdjustment *adj)
{
  return (int) gtk_adjustment_get_upper (adj);
}

static int
adjustment_get_page_size (GtkAdjustment *adj)
{
  return (int) gtk_adjustment_get_page_size (adj);
}

/* GtkDrawingArea draw function bridge.
   GTK4 removed the 'draw' signal.  Instead, gtk_drawing_area_set_draw_func()
   accepts a C callback.  This bridge installs a custom GObject signal
   'gst-draw' on GtkDrawingArea and sets a draw function that emits it,
   so Smalltalk code can connect to 'gst-draw' using the normal signal
   mechanism.  Signal signature: (GtkDrawingArea, cairo_t*) -> gboolean.  */

static guint gst_draw_signal_id = 0;

static void
gst_drawing_area_draw_func (GtkDrawingArea *area, cairo_t *cr,
                            int width, int height, gpointer user_data)
{
  gboolean result = FALSE;
  g_signal_emit (area, gst_draw_signal_id, 0, cr, &result);
}

void
gst_gtk_drawing_area_connect_draw (GtkDrawingArea *area)
{
  if (gst_draw_signal_id == 0)
    {
      gst_draw_signal_id =
        g_signal_new ("gst-draw",
                      GTK_TYPE_DRAWING_AREA,
                      G_SIGNAL_RUN_LAST,
                      0, NULL, NULL,
                      NULL, /* default marshaller */
                      G_TYPE_BOOLEAN, 1,
                      G_TYPE_POINTER); /* cairo_t* */
    }
  gtk_drawing_area_set_draw_func (area, gst_drawing_area_draw_func,
                                  NULL, NULL);
}

/* GtkTreeListModel bridge.
   GtkTreeListModel requires a C function pointer callback to create child
   models.  This bridge registers a custom GObject signal 'gst-create-children'
   on GtkTreeListModel and uses a C callback that emits it, so Smalltalk code
   can return a GListModel (or nil for leaf nodes) from a signal handler.
   Signal signature: (GtkTreeListModel, gint id) -> gpointer (GListModel* or NULL).
   The callback extracts the integer ID from the GtkStringObject item.  */

typedef struct {
  GtkTreeListModel *model;
} GstTreeListBridge;

static guint gst_create_children_signal_id = 0;

static GListModel *
gst_tree_list_create_func (gpointer item, gpointer user_data)
{
  GstTreeListBridge *bridge = (GstTreeListBridge *) user_data;
  const char *id_str;
  int id;
  gpointer result = NULL;

  id_str = gtk_string_object_get_string (GTK_STRING_OBJECT (item));
  id = atoi (id_str);
  g_signal_emit (bridge->model, gst_create_children_signal_id, 0, id, &result);
  return result ? G_LIST_MODEL (result) : NULL;
}

static void
gst_tree_list_bridge_free (gpointer data)
{
  g_free (data);
}

GtkTreeListModel *
gst_gtk_tree_list_model_new (GListModel *root,
                             int passthrough,
                             int autoexpand)
{
  GstTreeListBridge *bridge;
  GtkTreeListModel *model;

  if (gst_create_children_signal_id == 0)
    {
      gst_create_children_signal_id =
        g_signal_new ("gst-create-children",
                      gtk_tree_list_model_get_type (),
                      G_SIGNAL_RUN_LAST,
                      0, NULL, NULL,
                      NULL, /* default marshaller */
                      G_TYPE_POINTER, 1,
                      G_TYPE_INT);
    }

  bridge = g_new0 (GstTreeListBridge, 1);
  model = gtk_tree_list_model_new (root, passthrough, autoexpand,
                                   gst_tree_list_create_func, bridge,
                                   gst_tree_list_bridge_free);
  bridge->model = model;
  return model;
}

/* Initialization.  */

/* GTK4: GdkScreen and gdk_get_default_root_window() removed.
   Use GdkMonitor API to get screen dimensions. */
static GdkRectangle *
screen_get_geometry (void)
{
  static GdkRectangle geom = { 0, 0, 0, 0 };
  GdkDisplay *display = gdk_display_get_default ();
  GListModel *monitors;
  GdkMonitor *monitor;

  if (!display) return &geom;
  monitors = gdk_display_get_monitors (display);
  if (!monitors || g_list_model_get_n_items (monitors) == 0) return &geom;

  monitor = g_list_model_get_item (monitors, 0);
  if (!monitor) return &geom;

  gdk_monitor_get_geometry (monitor, &geom);
  g_object_unref (monitor);
  return &geom;
}

static int
screen_get_monitor_width_mm (void)
{
  GdkDisplay *display = gdk_display_get_default ();
  GListModel *monitors;
  GdkMonitor *monitor;
  int mm;

  if (!display) return 0;
  monitors = gdk_display_get_monitors (display);
  if (!monitors || g_list_model_get_n_items (monitors) == 0) return 0;

  monitor = g_list_model_get_item (monitors, 0);
  if (!monitor) return 0;

  mm = gdk_monitor_get_width_mm (monitor);
  g_object_unref (monitor);
  return mm;
}

static int
screen_get_monitor_height_mm (void)
{
  GdkDisplay *display = gdk_display_get_default ();
  GListModel *monitors;
  GdkMonitor *monitor;
  int mm;

  if (!display) return 0;
  monitors = gdk_display_get_monitors (display);
  if (!monitors || g_list_model_get_n_items (monitors) == 0) return 0;

  monitor = g_list_model_get_item (monitors, 0);
  if (!monitor) return 0;

  mm = gdk_monitor_get_height_mm (monitor);
  g_object_unref (monitor);
  return mm;
}

/* GtkStringList insert helper: splice to insert at arbitrary position */
static void
gst_gtk_string_list_insert (GtkStringList *list, guint position, const char *string)
{
  const char *strings[] = { string, NULL };
  gtk_string_list_splice (list, position, 0, strings);
}

static int initialized = 0;

int
gst_gtk_initialized ()
{
  return initialized;
}

void
gst_initModule (proxy)
     VMProxy *proxy;
{
  /* GTK4: gtk_init_check() takes no arguments. */
  initialized = gtk_init_check ();

  _gtk_vm_proxy = proxy;
  _gtk_vm_proxy->defineCFunc ("gstGtkGetState", widget_get_state);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetFlags", widget_get_flags);
  _gtk_vm_proxy->defineCFunc ("gstGtkSetFlags", widget_set_flags);
  _gtk_vm_proxy->defineCFunc ("gstGtkUnsetFlags", widget_unset_flags);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetSurface", widget_get_surface);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetHscrollbarVisible", scrolled_window_get_hscrollbar_visible);
  _gtk_vm_proxy->defineCFunc ("gstGtkGetVscrollbarVisible", scrolled_window_get_vscrollbar_visible);
  _gtk_vm_proxy->defineCFunc ("gstGtkAdjustmentGetLower", adjustment_get_lower);
  _gtk_vm_proxy->defineCFunc ("gstGtkAdjustmentGetUpper", adjustment_get_upper);
  _gtk_vm_proxy->defineCFunc ("gstGtkAdjustmentGetPageSize", adjustment_get_page_size);
  _gtk_vm_proxy->defineCFunc ("gstGtkWidgetGetAllocation", widget_get_allocation);
  _gtk_vm_proxy->defineCFunc ("gstGtkDialogGetVBox", dialog_get_vbox);
  _gtk_vm_proxy->defineCFunc ("gstGtkDrawingAreaConnectDraw", gst_gtk_drawing_area_connect_draw);
  _gtk_vm_proxy->defineCFunc ("gstGtkScreenGetGeometry", screen_get_geometry);
  _gtk_vm_proxy->defineCFunc ("gstGtkScreenGetMonitorWidthMm", screen_get_monitor_width_mm);
  _gtk_vm_proxy->defineCFunc ("gstGtkScreenGetMonitorHeightMm", screen_get_monitor_height_mm);
  _gtk_vm_proxy->defineCFunc ("gstGtkTreeListModelNew", gst_gtk_tree_list_model_new);
  _gtk_vm_proxy->defineCFunc ("gstGtkStringListInsert", gst_gtk_string_list_insert);

  _gtk_vm_proxy->defineCFunc ("gtk_placer_get_type", gtk_placer_get_type);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_new", gtk_placer_new);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_put", gtk_placer_put);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_move", gtk_placer_move);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_resize", gtk_placer_resize);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_move_rel", gtk_placer_move_rel);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_resize_rel", gtk_placer_resize_rel);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_set_has_window", gtk_placer_set_has_window);
  _gtk_vm_proxy->defineCFunc ("gtk_placer_get_has_window", gtk_placer_get_has_window);

  _gtk_vm_proxy->dlPushSearchPath ();
#include "libs.def"
  _gtk_vm_proxy->dlPopSearchPath ();
}
