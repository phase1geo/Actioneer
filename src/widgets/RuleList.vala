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

public class RuleList : EnableList {

  public static const Gtk.TargetEntry[] DRAG_TARGETS = {
    {"text/uri-list", 0, DragTypes.URI},
  };

  private Box _current_box;

  public signal void execute( int index, string fname );
  public signal bool duplicated( int index, ref bool enable, ref string label );
  public signal void move_rule( int rule_index, int dir_index );
  public signal void copy_rule( int rule_index, int dir_index );

  /* Create the main window UI */
  public RuleList( MainWindow w ) {

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

  protected override Gtk.Menu? get_contextual_menu( int index ) {

    var menu = new Gtk.Menu();

    var dup = new Gtk.MenuItem.with_label( _( "Duplicate" ) );
    dup.activate.connect(() => {
      bool   enable = true;
      string label  = "";
      if( duplicated( index, ref enable, ref label ) ) {
        var row = (int)list_box.get_children().length();
        add_row( enable, label );
        select_row( row );
        selected( row );
      }
    });

    var move_menu = new Gtk.Menu();
    var copy_menu = new Gtk.Menu();
    var dirs = win.get_app().dirlist;

    for( int i=0; i<dirs.size(); i++ ) {
      int dir_index = i;
      if( dirs.get_directory( i ) != dirs.current_dir ) {
        var move_dir = new Gtk.MenuItem.with_label( dirs.get_directory( i ).dirname );
        move_dir.activate.connect(() => {
          move_rule( index, dir_index );
          select_row( -1 );
          list_box.remove( list_box.get_children().nth_data( index ) );
          selected( -1 );
        });
        var copy_dir = new Gtk.MenuItem.with_label( dirs.get_directory( i ).dirname );
        copy_dir.activate.connect(() => {
          copy_rule( index, dir_index );
        });
        move_menu.add( move_dir );
        copy_menu.add( copy_dir );
      }
    }

    var move = new Gtk.MenuItem.with_label( _( "Move To Directory" ) );
    move.set_submenu( move_menu );

    var copy = new Gtk.MenuItem.with_label( _( "Copy To Directory" ) );
    copy.set_submenu( copy_menu );

    menu.add( dup );
    menu.add( new Gtk.SeparatorMenuItem() );
    menu.add( move );
    menu.add( copy );
    menu.show_all();

    return( menu );

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
    return( _( "Rules" ) );
  }

  protected override string add_tooltip() {
    return( Utils.tooltip_with_accel( _( "Add Rule" ), "<Control>n" ) );
  }

  protected override string remove_tooltip() {
    return( _( "Remove Selected Rule" ) );
  }

  public override string? get_label() {
    return( _( "New Rule" ) );
  }

}

