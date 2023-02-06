/*
* Copyright (c) 2022 (https://github.com/phase1geo/Actioneer)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using Gtk;

public class PinList : EnableList {

  public static const Gtk.TargetEntry[] DRAG_TARGETS = {
    {"text/uri-list", 0, DragTypes.URI},
  };

  private Box _current_box;

  public signal void execute( int index, string fname );

  /* Create the main window UI */
  public PinList( MainWindow w ) {

    base( w );

    /* Set ourselves up to be a drag target */
    Gtk.drag_dest_set( list_box, DestDefaults.MOTION | DestDefaults.DROP, DRAG_TARGETS, Gdk.DragAction.COPY );
    list_box.drag_motion.connect( handle_drag_motion );
    list_box.drag_data_received.connect( handle_drag_data_received );
    list_box.drag_leave.connect( handle_drag_leave );

  }

  private bool handle_drag_motion( Gdk.DragContext ctx, int x, int y, uint t ) {
    return( highlight_row( (double)y ) );
  }

  private void handle_drag_data_received( Gdk.DragContext ctx, int x, int y, Gtk.SelectionData data, uint info, uint t ) {
    if( info == DragTypes.URI ) {
      if( _current_box != null ) {
        var index = get_index_for_y( (double)y );
        foreach (var uri in data.get_uris()) {
          var fname = Filename.from_uri( uri );
          execute( index, fname );
        }
      }
    }
    if( _current_box != null ) {
      _current_box.get_style_context().remove_class( "rulelist-droppable" );
    }
    Gtk.drag_finish( ctx, true, false, t );
  }

  private void handle_drag_leave( Gdk.DragContext ctx, uint t ) {
    if( _current_box != null ) {
      _current_box.get_style_context().remove_class( "rulelist-droppable" );
    }
  }

  /* Causes the given row to be selected */
  private bool highlight_row( double y ) {

    if( _current_box != null ) {
      _current_box.get_style_context().remove_class( "rulelist-droppable" );
    }

    var box = get_box_for_y( y );
    if( box != null ) {
      box.get_style_context().add_class( "rulelist-droppable" );
    }

    _current_box = box;

    return( _current_box != null );

  }

  protected virtual SelectionMode select_mode() {
    return( SelectionMode.SINGLE );
  }

  protected override string title() {
    return( _( "Pinned Rules" ) );
  }

  protected override bool enables_exist() {
    return( false );
  }

  protected override bool add_button_exists() {
    return( false );
  }

  protected override string remove_tooltip() {
    return( _( "Remove Selected Rule" ) );
  }

  public override string? get_label() {
    return( _( "New Rule" ) );
  }

}

