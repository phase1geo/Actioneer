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

public class EnableList : Box {

  private Button      _del_btn;
  private Overlay     _overlay;
  private Box         _list_box;
  private DrawingArea _move_blank;
  private MoveState   _move_state       = MoveState.NONE;
  private Box?        _move_box         = null;
  private int         _move_start_index = -1;
  private int         _move_last_index  = -1;
  private Allocation  _move_alloc;
  private double      _move_offset;
  private int         _select_index     = -1;

  protected MainWindow  win;

  public signal void enable_changed( int index );
  public signal bool added( string pathname );
  public signal void removed( int index );
  public signal void moved( int from, int to );
  public signal void selected( int index );

  /* Create the main window UI */
  public EnableList( MainWindow w ) {

    Object( orientation: Orientation.VERTICAL, spacing: 0 );

    win = w;

    create_pane();

    /* Display the UI */
    show_all();

  }

  private void create_pane() {

    var lbl = new Label( "<b>" + title() + "</b>" );
    lbl.use_markup = true;
    lbl.margin = 10;

    /* Create button bar at the bottom of the pane */
    var add_btn = new Button.from_icon_name( "list-add-symbolic", IconSize.SMALL_TOOLBAR );
    add_btn.set_tooltip_text( add_tooltip() );
    add_btn.clicked.connect( action_add );

    _del_btn = new Button.from_icon_name( "list-remove-symbolic", IconSize.SMALL_TOOLBAR );
    _del_btn.set_tooltip_text( remove_tooltip() );
    _del_btn.set_sensitive( false );
    _del_btn.clicked.connect( action_remove );

    var bbox = new Box( Orientation.HORIZONTAL, 5 );
    bbox.margin = 5;
    bbox.pack_start( add_btn,  false, false, 0 );
    bbox.pack_start( _del_btn, false, false, 0 );

    /* Create list */
    _list_box   = new Box( Orientation.VERTICAL, 0 );
    _move_blank = new DrawingArea();

    var ebox = new EventBox();

    ebox.button_press_event.connect((e) => {
      _move_box = get_box_for_y( e.y );
      if( _move_box == null ) {
        select_row( -1 );
        selected( _select_index );
      } else {
        _move_state = MoveState.PRESS;
        _move_box.get_allocation( out _move_alloc );
        _move_offset = e.y - _move_alloc.y;
        _move_blank.set_size_request( _move_alloc.width, _move_alloc.height );
        _move_start_index = get_index_for_y( e.y );
        _move_last_index  = _move_start_index;
      }
      return( true );
    });

    ebox.button_release_event.connect((e) => {
      if( _move_state == MoveState.PRESS ) {
        select_row( _move_start_index );
        selected( _select_index );
      } else if( _move_state == MoveState.MOVE ) {
        _overlay.remove( _move_box );
        _move_box.margin_top = 0;
        _list_box.remove( _move_blank );
        _list_box.pack_start( _move_box, false, true, 0 );
        _list_box.reorder_child( _move_box, _move_last_index );
        _overlay.show_all();
        move_row( _move_start_index, _move_last_index );
      }
      _move_state = MoveState.NONE;
      return( true );
    });

    ebox.motion_notify_event.connect((e) => {
      var index = get_index_for_y( e.y );
      if( _move_state != MoveState.NONE ) {
        if( _move_state == MoveState.PRESS ) {
          _list_box.pack_start( _move_blank, false, true, 0 );
          _list_box.reorder_child( _move_blank, _move_last_index );
          _list_box.remove( _move_box );
          _move_box.margin_top = _move_alloc.y;
          _move_box.halign     = Align.FILL;
          _move_box.valign     = Align.START;
          _overlay.add_overlay( _move_box );
          _move_state = MoveState.MOVE;
        } else {
          var top = (int)(e.y - _move_offset);
          if( (top >= 0) && ((top + _move_alloc.height) < _list_box.get_allocated_height()) ) {
            _move_box.margin_top = (int)(e.y - _move_offset);
          }
          if( index != _move_last_index ) {
            _list_box.reorder_child( _move_blank, index );
          }
        }
        _overlay.show_all();
      }
      _move_last_index = index;
      return( true );
    });

    ebox.add( _list_box );

    _overlay = new Overlay();
    _overlay.add( ebox );

    var list_sw = new ScrolledWindow( null, null );
    list_sw.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC );
    list_sw.add( _overlay );

    /* Pack everything in the pane */
    pack_start( lbl,     false, true, 0 );
    pack_start( list_sw, true,  true, 0 );
    pack_end(   bbox,    false, true, 0 );

  }

  private int get_index_for_y( double y ) {
    var index = -1;
    var i     = 0;
    _list_box.get_children().foreach((b) => {
      Allocation alloc;
      b.get_allocation( out alloc );
      if( (alloc.y <= y) && (y < (alloc.y + alloc.height + 10)) ) {
        index = i;
      }
      i++;
    });
    return( index );
  }

  private Box? get_box_for_y( double y ) {
    Box box = null;
    _list_box.get_children().foreach((b) => {
      Allocation alloc;
      b.get_allocation( out alloc );
      if( (alloc.y <= y) && (y < (alloc.y + alloc.height + 10)) ) {
        box = (Box)b;
      }
    });
    return( box );
  }

  protected virtual string title() {
    assert( false );
    return( "" );
  }

  protected virtual string add_tooltip() {
    assert( false );
    return( "" );
  }

  protected virtual string remove_tooltip() {
    assert( false );
    return( "" );
  }

  /*
   Returns the string to display in the row.  If null is returned,
   we will avoid adding the new row.
  */
  protected virtual string? get_label() {
    return( null );
  }

  /* Clears all of the items from this box */
  public void clear() {

    _list_box.get_children().foreach((c) => {
      _list_box.remove( c );
    });

    select_row( -1 );

  }

  /* Sets the label of the currently selected item to the given value */
  public void set_label( string label ) {

    var box = (Box)_list_box.get_children().nth_data( _select_index );
    var lbl = (Label)box.get_children().nth_data( 1 );
    lbl.label = label;

  }

  /* Causes the given row to be selected */
  public void select_row( int index ) {

    /* Deselect the previous index */
    if( _select_index != -1 ) {
      var last_box = _list_box.get_children().nth_data( _select_index );
      last_box.get_style_context().remove_class( "enablelist-selected" );
    }

    if( index != -1 ) {
      var box = _list_box.get_children().nth_data( index );
      box.get_style_context().add_class( "enablelist-selected" );
    }

    _del_btn.set_sensitive( index != -1 );
    _select_index = index;

  }

  /*
   Make sure that if this method is overridden that th extended class
   calls this method.
  */
  public void add_row( bool enable, string label ) {
    
    var box = new Box( Orientation.HORIZONTAL, 10 );
    box.margin_start = 5;
    box.margin_end   = 5;
    box.get_style_context().add_class( "enablelist-padding" );

    var cb = new CheckButton();
    cb.active = enable;
    cb.toggled.connect(() => {
      enable_changed( _list_box.get_children().index( box ) );
    });

    var lbl = new Label( label );
    // lbl.ypad = 5;

    box.pack_start( cb,  false, false, 0 );
    box.pack_start( lbl, false, true,  0 );

    _list_box.pack_start( box, false, false, 0 );
    _list_box.show_all();

  }

  public void action_add() {
    var label = get_label();
    if( label != null ) {
      if( added( label ) ) {
        var row = (int)_list_box.get_children().length();
        add_row( true, label );
        select_row( row );
        selected( row );
      }
    }
  }

  public void action_remove() {
    var index = _select_index;
    select_row( -1 );
    _list_box.remove( _list_box.get_children().nth_data( index ) );
    removed( index );
    selected( -1 );
  }

  protected virtual void move_row( int from, int to ) {
    moved( from, to );
  }

}

