/***********************************************************************
 *
 *  GTK wrappers for GNU Smalltalk - Placer geometry manager
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

/* Rubber-sheet geometry manager for BLOX.
   GTK4 port: GtkContainer removed, now a direct GtkWidget subclass.  */

#include "placer.h"

static void gtk_placer_measure       (GtkWidget      *widget,
                                      GtkOrientation  orientation,
                                      int             for_size,
                                      int            *minimum,
                                      int            *natural,
                                      int            *minimum_baseline,
                                      int            *natural_baseline);
static void gtk_placer_size_allocate (GtkWidget      *widget,
                                      int             width,
                                      int             height,
                                      int             baseline);
static void gtk_placer_dispose       (GObject        *object);

G_DEFINE_TYPE (GtkPlacer, gtk_placer, GTK_TYPE_WIDGET)

static void
gtk_placer_class_init (GtkPlacerClass *class)
{
  GObjectClass *gobject_class = G_OBJECT_CLASS (class);
  GtkWidgetClass *widget_class = GTK_WIDGET_CLASS (class);

  gobject_class->dispose = gtk_placer_dispose;
  widget_class->measure = gtk_placer_measure;
  widget_class->size_allocate = gtk_placer_size_allocate;
}

static void
gtk_placer_init (GtkPlacer *placer)
{
  placer->children = NULL;
}

static void
gtk_placer_dispose (GObject *object)
{
  GtkPlacer *placer = GTK_PLACER (object);
  GtkPlacerChild *child;
  GList *children;

  children = placer->children;
  while (children)
    {
      child = children->data;
      children = children->next;
      gtk_widget_unparent (child->widget);
      g_free (child);
    }
  g_list_free (placer->children);
  placer->children = NULL;

  G_OBJECT_CLASS (gtk_placer_parent_class)->dispose (object);
}

GtkWidget*
gtk_placer_new (void)
{
  return g_object_new (GTK_TYPE_PLACER, NULL);
}

static GtkPlacerChild*
get_child (GtkPlacer  *placer,
           GtkWidget  *widget)
{
  GList *children;

  children = placer->children;
  while (children)
    {
      GtkPlacerChild *child;

      child = children->data;
      children = children->next;

      if (child->widget == widget)
        return child;
    }

  return NULL;
}

void
gtk_placer_put (GtkPlacer     *placer,
                GtkWidget     *widget,
                gint           x,
                gint           y,
		gint	       width,
	        gint	       height,
		gint	       rel_x,
		gint	       rel_y,
		gint	       rel_width,
		gint	       rel_height)
{
  GtkPlacerChild *child_info;

  g_return_if_fail (GTK_IS_PLACER (placer));
  g_return_if_fail (GTK_IS_WIDGET (widget));
  g_return_if_fail ((rel_x & ~32767) == 0);
  g_return_if_fail ((rel_y & ~32767) == 0);
  g_return_if_fail ((rel_width & ~32767) == 0);
  g_return_if_fail ((rel_height & ~32767) == 0);

  child_info = g_new (GtkPlacerChild, 1);
  child_info->widget = widget;
  child_info->x = x;
  child_info->y = y;
  child_info->width = width;
  child_info->height = height;
  child_info->rel_x = rel_x;
  child_info->rel_y = rel_y;
  child_info->rel_width = rel_width;
  child_info->rel_height = rel_height;

  placer->children = g_list_append (placer->children, child_info);
  gtk_widget_set_parent (widget, GTK_WIDGET (placer));
}

static void
gtk_placer_move_internal (GtkPlacer      *placer,
                          GtkWidget      *widget,
                          gboolean        change_x,
                          gint            x,
                          gboolean        change_y,
                          gint            y,
			  gboolean	  change_width,
			  gint		  width,
			  gboolean	  change_height,
			  gint		  height,
                          gboolean        change_rel_x,
                          gint            rel_x,
                          gboolean        change_rel_y,
                          gint            rel_y,
			  gboolean	  change_rel_width,
			  gint		  rel_width,
			  gboolean	  change_rel_height,
			  gint		  rel_height)
{
  GtkPlacerChild *child;

  g_return_if_fail (GTK_IS_PLACER (placer));
  g_return_if_fail (GTK_IS_WIDGET (widget));
  g_return_if_fail (gtk_widget_get_parent (widget) == GTK_WIDGET (placer));
  g_return_if_fail (!change_rel_x || (rel_x & ~32767) == 0);
  g_return_if_fail (!change_rel_y || (rel_y & ~32767) == 0);
  g_return_if_fail (!change_rel_width || (rel_width & ~32767) == 0);
  g_return_if_fail (!change_rel_height || (rel_height & ~32767) == 0);

  child = get_child (placer, widget);

  g_assert (child);

  if (change_x) child->x = x;
  if (change_y) child->y = y;
  if (change_width) child->width = width;
  if (change_height) child->height = height;
  if (change_rel_x) child->rel_x = rel_x;
  if (change_rel_y) child->rel_y = rel_y;
  if (change_rel_width) child->rel_width = rel_width;
  if (change_rel_height) child->rel_height = rel_height;

  if (gtk_widget_get_visible (widget) &&
      gtk_widget_get_visible (GTK_WIDGET (placer)))
    gtk_widget_queue_resize (GTK_WIDGET (placer));
}

void
gtk_placer_move (GtkPlacer      *placer,
                 GtkWidget      *widget,
                 gint            x,
                 gint            y)
{
  gtk_placer_move_internal (placer, widget,
			    TRUE, x, TRUE, y,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0);
}

void
gtk_placer_resize (GtkPlacer      *placer,
                   GtkWidget      *widget,
                   gint            width,
                   gint            height)
{
  gtk_placer_move_internal (placer, widget,
			    FALSE, 0, FALSE, 0,
			    TRUE, width, TRUE, height,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0);
}

void
gtk_placer_move_rel (GtkPlacer      *placer,
                     GtkWidget      *widget,
                     gint            rel_x,
                     gint            rel_y)
{
  gtk_placer_move_internal (placer, widget,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    TRUE, rel_x, TRUE, rel_y,
			    FALSE, 0, FALSE, 0);
}

void
gtk_placer_resize_rel (GtkPlacer      *placer,
                       GtkWidget      *widget,
                       gint            rel_width,
                       gint            rel_height)
{
  gtk_placer_move_internal (placer, widget,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    FALSE, 0, FALSE, 0,
			    TRUE, rel_width, TRUE, rel_height);
}

static void
gtk_placer_compute_size (GtkPlacer *placer,
                         gint      *out_width,
                         gint      *out_height)
{
  GtkPlacerChild *child;
  GList *children;
  gint child_min_width, child_min_height;
  gint height, width;
  gint req_width = 0, req_height = 0;

  children = placer->children;
  while (children)
    {
      child = children->data;
      children = children->next;

      if (gtk_widget_get_visible (child->widget))
	{
          gtk_widget_measure (child->widget, GTK_ORIENTATION_HORIZONTAL,
                              -1, &child_min_width, NULL, NULL, NULL);
          gtk_widget_measure (child->widget, GTK_ORIENTATION_VERTICAL,
                              -1, &child_min_height, NULL, NULL, NULL);

	  height = child_min_height - child->height;
	  width = child_min_width - child->width;

	  if (child->rel_height)
	    height = height / (child->rel_height / 32767.0);
	  else
	    height = height / (1.0 - child->rel_y / 32767.0);

	  if (child->rel_width)
	    width = width / (child->rel_width / 32767.0);
	  else
	    width = width / (1.0 - child->rel_x / 32767.0);

	  req_height = MAX (height + child->y, req_height);
	  req_width = MAX (width + child->x, req_width);
	}
    }

  if (out_width)
    *out_width = req_width;
  if (out_height)
    *out_height = req_height;
}

static void
gtk_placer_measure (GtkWidget      *widget,
                    GtkOrientation  orientation,
                    int             for_size,
                    int            *minimum,
                    int            *natural,
                    int            *minimum_baseline,
                    int            *natural_baseline)
{
  GtkPlacer *placer = GTK_PLACER (widget);
  gint width, height;

  gtk_placer_compute_size (placer, &width, &height);

  if (orientation == GTK_ORIENTATION_HORIZONTAL)
    {
      if (minimum) *minimum = width;
      if (natural) *natural = width;
    }
  else
    {
      if (minimum) *minimum = height;
      if (natural) *natural = height;
    }

  if (minimum_baseline) *minimum_baseline = -1;
  if (natural_baseline) *natural_baseline = -1;
}

static void
gtk_placer_size_allocate (GtkWidget *widget,
                          int        width,
                          int        height,
                          int        baseline)
{
  GtkPlacer *placer;
  GtkPlacerChild *child;
  GtkAllocation child_allocation;
  GList *children;
  gdouble rel_width_scale, rel_height_scale;
  int child_min_w, child_min_h;

  placer = GTK_PLACER (widget);

  rel_width_scale = width / 32767.0;
  rel_height_scale = height / 32767.0;

  children = placer->children;
  while (children)
    {
      child = children->data;
      children = children->next;

      if (gtk_widget_get_visible (child->widget))
	{
          gtk_widget_measure (child->widget, GTK_ORIENTATION_HORIZONTAL,
                              -1, &child_min_w, NULL, NULL, NULL);
          gtk_widget_measure (child->widget, GTK_ORIENTATION_VERTICAL,
                              -1, &child_min_h, NULL, NULL, NULL);

	  child_allocation.x = child->x + (int)(child->rel_x * rel_width_scale);
	  child_allocation.y = child->y + (int)(child->rel_y * rel_height_scale);

	  if (!child->rel_width)
	    child_allocation.width = child_min_w;
	  else
	    child_allocation.width = (int)(child->rel_width * rel_width_scale);

	  if (!child->rel_height)
	    child_allocation.height = child_min_h;
	  else
	    child_allocation.height = (int)(child->rel_height * rel_height_scale);

	  child_allocation.width += child->width;
	  child_allocation.height += child->height;

	  child_allocation.width = MAX (child_allocation.width, 0);
	  child_allocation.height = MAX (child_allocation.height, 0);
	  gtk_widget_size_allocate (child->widget, &child_allocation, -1);
	}
    }
}

void
gtk_placer_remove (GtkPlacer *placer,
                   GtkWidget *widget)
{
  GtkPlacerChild *child;
  GList *children;

  g_return_if_fail (GTK_IS_PLACER (placer));

  children = placer->children;
  while (children)
    {
      child = children->data;

      if (child->widget == widget)
	{
	  gtk_widget_unparent (widget);

	  placer->children = g_list_remove_link (placer->children, children);
	  g_list_free (children);
	  g_free (child);

	  gtk_widget_queue_resize (GTK_WIDGET (placer));
	  break;
	}

      children = children->next;
    }
}

/* GTK4: has_window concept removed. These are no-ops for
   backwards compatibility with existing Smalltalk code. */

void
gtk_placer_set_has_window (GtkPlacer *placer,
			   gboolean  has_window)
{
  g_return_if_fail (GTK_IS_PLACER (placer));
  /* No-op in GTK4: the has_window concept was removed. */
}

gboolean
gtk_placer_get_has_window (GtkPlacer *placer)
{
  g_return_val_if_fail (GTK_IS_PLACER (placer), FALSE);
  /* GTK4: all widgets manage their own rendering. */
  return FALSE;
}
