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

  private Box _current_box;

  private const GLib.ActionEntry[] action_entries = {
    { "action_duplicate",      action_duplicate,      "d" },
    { "action_move_directory", action_move_directory, "s" },
    { "action_copy_directory", action_copy_directory, "s" },
  };

  public signal void execute( int index, string fname );
  public signal bool duplicated( int index, ref bool enable, ref string label );
  public signal void move_rule( int rule_index, int dir_index );
  public signal void copy_rule( int rule_index, int dir_index );

  /* Create the main window UI */
  public RuleList( MainWindow w ) {

    base( w );

    /* Set ourselves up to be a drag target */
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

    /* Set the stage for menu actions */
    var actions = new SimpleActionGroup ();
    actions.add_action_entries( action_entries, this );
    insert_action_group( "rulelist", actions );

  }

  private bool handle_drop( Value val, double x, double y ) {
    if( _current_box != null ) {
      var index = get_index_for_y( (double)y );
      var uri   = val.get_string();
      var fname = Filename.from_uri( uri );
      execute( index, fname );
      _current_box.get_style_context().remove_class( "rulelist-droppable" );
      return( true );
    }
    return( false );
  }

  /* Populates and returns the contextual menu */
  protected override GLib.Menu? get_contextual_menu( int index ) {

    var dup_menu = new GLib.Menu();
    dup_menu.append( _( "Duplicate" ), "rulelist.action_duplicate('%d')".printf( index ) );

    var move_menu = new GLib.Menu();
    var copy_menu = new GLib.Menu();
    var dirs      = win.get_app().dirlist;

    for( int i=0; i<dirs.size(); i++ ) {
      int dir_index = i;
      if( dirs.get_directory( i ) != dirs.current_dir ) {
        move_menu.append( dirs.get_directory( i ).dirname, "action_move_directory('%d:%d')".printf( index, i ) );
        copy_menu.append( dirs.get_directory( i ).dirname, "action_copy_directory('%d:%d')".printf( index, i ) );
      }
    }

    var other_menu = new GLib.Menu();
    other_menu.append_submenu( _( "Move To Directory" ), move_menu );
    other_menu.append_submenu( _( "Copy To Directory" ), copy_menu );

    var menu = new GLib.Menu();
    menu.append_section( null, dup_menu );
    menu.append_section( null, other_menu );

    return( menu );

  }

  /* Performs duplication action */
  private void action_duplicate( SimpleAction action, Variant? variant ) {
    if( variant != null ) {
      var index  = variant.get_int32();
      var enable = true;
      var label  = "";
      if( duplicated( index, ref enable, ref label ) ) {
        var row = (int)list_box.get_children().length();
        add_row( enable, label, true );
        select_row( row );
        selected( row );
      }
    }
  }

  /* Moves the directory */
  private void action_move_directory( SimpleAction action, Variant? variant ) {
    if( variant != null ) {
      var val       = variant.get_string();
      var vals      = val.split( ":" );
      var index     = int.parse( vals[0] );
      var dir_index = int.parse( vals[1] );
      move_rule( index, dir_index );
      select_row( -1 );
      list_box.remove( list_box.get_children().nth_data( index ) );
      selected( -1 );
    }
  }

  /* Copies the directory */
  private void action_copy_directory( SimpleAction action, Variant? variant ) {
    if( variant != null ) {
      var val       = variant.get_string();
      var vals      = val.split( ":" );
      var index     = int.parse( vals[0] );
      var dir_index = int.parse( vals[1] );
      copy_rule( index, dir_index );
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

