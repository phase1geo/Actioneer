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

  private Box _current_box;

  public signal void execute( int index, string fname );

  /* Create the main window UI */
  public PinList( MainWindow w ) {

    base( w );

    var drop = new DropTarget( Type.STRING, Gdk.DragAction.COPY );

    drop.motion.connect((x, y) => {
      return( highlight_row( y ) ? Gdk.DragAction.COPY : 0 );
    });
    drop.leave.connect(() => {
      if( _current_box != null ) {
        _current_box.get_style_context().remove_class( "rulelist-droppable" );
      }
    });
    drop.drop.connect( handle_drop );

    add_controller( drop );

  }

  private bool handle_drop( Value val, double x, int y ) {
    if( _current_box != null ) {
      var index = get_index_for_y( y );
      var uri   = val.get_string();
      var fname = Filename.from_uri( uri );
      execute( index, fname );
      _current_box.get_style_context().remove_class( "rulelist-droppable" );
      return( true );
    }
    return( false );
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

  protected override bool del_button_exists() {
    return( false );
  }

  protected override string remove_tooltip() {
    return( _( "Remove Selected Rule" ) );
  }

  public override string? get_label() {
    return( _( "New Rule" ) );
  }

}

