using Gtk;
using Gdk;

public enum MoveState {
  NONE,
  PRESS,
  MOVE
}

public class BoxList : Box {

  private Overlay     _overlay;
  private Box         _list_box;
  private Box         _move_blank;
  private MoveState   _move_state       = MoveState.NONE;
  private Box?        _move_box         = null;
  private int         _move_start_index = -1;
  private int         _move_last_index  = -1;
  private Allocation  _move_alloc;
  private double      _move_offset;

  protected OptMenu mb;

  /* Default constructor */
  public BoxList( string add_label ) {

    Object( orientation: Orientation.VERTICAL, spacing: 10 );

    _list_box   = new Box( Orientation.VERTICAL, 10 );
    _move_blank = new Box( Orientation.HORIZONTAL, 10 );
    _move_blank.margin_left = 10;

    var mb = get_option_menu();
    mb.opacity = 0.0;
    _move_blank.pack_start( mb, false, false, 0 );

    var ebox = new EventBox();

    ebox.button_press_event.connect((e) => {
      _move_state = MoveState.PRESS;
      _move_box   = get_box_for_y( e.y );
      _move_box.get_allocation( out _move_alloc );
      _move_offset = e.y - _move_alloc.y;
      _move_start_index = get_index_for_y( e.y );
      _move_last_index  = _move_start_index;
      return( true );
    });

    ebox.button_release_event.connect((e) => {
      if( _move_state == MoveState.MOVE ) {
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

    var bbox = new Box( Orientation.HORIZONTAL, 10 );

    var row_btn = new Button.with_label( add_label );
    row_btn.get_style_context().add_class( "add-item" );
    row_btn.clicked.connect(() => {
      add_row( 0, true );
    });
    bbox.pack_start( row_btn, false, false, 0 );

    if( group_supported() ) {
      var group_btn = new Button.with_label( _( "Add Group" ) );
      group_btn.get_style_context().add_class( "add-item" );
      group_btn.clicked.connect(() => {
        add_group();
      });
      bbox.pack_start( group_btn, false, false, 0 );
    }

    pack_start( _overlay, false, true, 0 );
    pack_start( bbox,     false, true, 0 );

    show_all();

  }

  protected virtual void add_row( int row_type, bool show_opt_menu ) {

    var box = new Box( Orientation.HORIZONTAL, 10 );
    box.margin_left = 10;

    var mb = get_option_menu();
    var ibox = new Box( Orientation.VERTICAL, 10 );

    mb.activated.connect((rt) => {
      if( ibox.get_children().length() > 0 ) {
        ibox.remove( ibox.get_children().nth_data( 0 ) );
      }
      set_row_content( get_index_for_box( box ), rt, ibox );
      ibox.show_all();
    });

    /* Add test result */
    var result = new Image.from_icon_name( "dialog-error", IconSize.LARGE_TOOLBAR );
    result.opacity = 0;

    /* Add close button */
    var close = new Button.from_icon_name( "window-close-symbolic", IconSize.SMALL_TOOLBAR );
    close.clicked.connect(() => {
      delete_row( get_index_for_box( box ) );
    });

    box.pack_start( mb,     false, false, 0 );
    box.pack_start( ibox,   false, true,  0 );
    box.pack_end(   close,  false, false, 0 );
    box.pack_end(   result, false, false, 0 );

    var revealer = new Revealer();
    revealer.transition_duration = 0;
    revealer.add( box );

    _list_box.pack_start( revealer, false, true, 0 ); 
    _list_box.show_all();

    mb.set_current_item( row_type );

    if( show_opt_menu ) {
      Idle.add(() => {
        mb.clicked();
        return( false );
      });
    }

  }

  protected virtual bool group_supported() {
    return( true );
  }

  protected virtual void add_group() {

    var box = new Box( Orientation.HORIZONTAL, 10 );
    box.margin_left = 10;

    var ibox = new Box( Orientation.VERTICAL, 10 );

    /* Add close button */
    var close = new Button.from_icon_name( "window-close-symbolic", IconSize.SMALL_TOOLBAR );
    close.clicked.connect(() => {
      delete_row( get_index_for_box( box ) );
    });

    var cbox = new Box( Orientation.VERTICAL, 10 );
    cbox.pack_start( close, false, false, 0 );

    box.pack_start( ibox, true, true,  0 );
    box.pack_end(   cbox, false, false, 0 );

    var revealer = new Revealer();
    revealer.transition_duration = 0;
    revealer.add( box );

    _list_box.pack_start( revealer, false, true, 0 ); 

    set_row_content( get_index_for_box( box ), (int)ActionConditionType.COND_GROUP, ibox );
    show_all();

  }

  private int get_index_for_box( Box box ) {
    var index = -1;
    var i     = 0;
    _list_box.get_children().foreach((r) => {
      var rev = (Revealer)r;
      if( (Box)rev.get_child() == box ) {
        index = i;
      }
      i++;
    });
    return( index );
  }

  private int get_index_for_y( double y ) {
    var index = -1;
    var i     = 0;
    _list_box.get_children().foreach((r) => {
      Allocation alloc;
      var rev = (Revealer)r;
      var b = (Box)rev.get_child();
      b.get_allocation( out alloc );
      if( (alloc.y <= y) && (y < (alloc.y + alloc.height + 10)) ) {
        index = i;
      }
      i++;
    });
    return( index );
  }
  
  private Box get_box_for_y( double y ) {
    Box box = null;
    _list_box.get_children().foreach((r) => {
      Allocation alloc;
      var rev = (Revealer)r;
      var b   = (Box)rev.get_child();
      b.get_allocation( out alloc );
      if( (alloc.y <= y) && (y < (alloc.y + alloc.height + 10)) ) {
        box = (Box)b;
      }
    });
    return( box );
  }

  public void set_test_result( int index, TestResult result ) {
    var row  = (Revealer)_list_box.get_children().nth_data( index );
    var box  = (Box)row.get_child();
    var rslt = (Image)box.get_children().nth_data( 2 );
    rslt.icon_name    = result.pass ? "emblem-default" : "dialog-error";
    rslt.tooltip_text = result.result;
    rslt.opacity      = 1;
  }

  protected virtual void delete_row( int index ) {
    _list_box.remove( _list_box.get_children().nth_data( index ) );
  }

  protected virtual void move_row( int from, int to ) {
    assert( false );
  }

  /* Make the row at the given index show or hide itself */
  public void set_row_visibility( int index, bool show ) {
    var r = (Revealer)_list_box.get_children().nth_data( index );
    r.reveal_child = show;
  }

  /* Removes all elements from this box list in the UI */
  public virtual void clear() {
    _list_box.get_children().foreach((item) => {
      _list_box.remove( item );
    });
  }

  protected virtual OptMenu get_option_menu() {
    assert( false );
    return( new OptMenu() );
  }

  protected virtual void set_row_content( int index, int row_type, Box box ) {
    assert( false );
  }

  public virtual void get_data( DirAction action ) {
    assert( false );
  }

  public virtual void set_data( DirAction action ) {
    assert( false );
  }

}
