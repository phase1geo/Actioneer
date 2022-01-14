using Gtk;

public class BoxList : Box {

  private Box _list_box;

  protected OptMenu mb;

  /* Default constructor */
  public BoxList( string add_label ) {

    Object( orientation: Orientation.VERTICAL, spacing: 10 );

    _list_box = new Box( Orientation.VERTICAL, 10 );

    var add_btn = new Button.with_label( add_label );
    add_btn.get_style_context().add_class( "add-item" );
    add_btn.clicked.connect(() => {
      add_row( 0 );
    });

    var bbox = new Box( Orientation.HORIZONTAL, 0 );
    bbox.pack_start( add_btn, false, false, 0 );

    pack_start( _list_box, false, true, 0 );
    pack_start( bbox,      false, true, 0 );

  }

  protected virtual void add_row( int row_type ) {

    var box = new Box( Orientation.HORIZONTAL, 10 );
    box.margin_left = 10;

    var mb = get_option_menu();
    var ibox = new Box( Orientation.VERTICAL, 10 );

    mb.activated.connect((rt) => {
      if( ibox.get_children().length() > 0 ) {
        ibox.remove( ibox.get_children().nth_data( 0 ) );
      }
      set_row_content( get_index( box ), rt, ibox );
      ibox.show_all();
    });

    /* Add close button */
    var close = new Button.from_icon_name( "window-close-symbolic", IconSize.SMALL_TOOLBAR );
    close.clicked.connect(() => {
      delete_row( get_index( box ) );
    });

    box.pack_start( mb,    false, false, 0 );
    box.pack_start( ibox,  false, true,  0 );
    box.pack_end(   close, false, false, 0 );

    _list_box.pack_start( box, false, true, 0 ); 
    _list_box.show_all();

    mb.set_current_item( row_type );

  }

  private int get_index( Box box ) {
    var index = -1;
    var i     = 0;
    _list_box.get_children().foreach((b) => {
      if( b == box ) {
        index = i;
      }
      i++;
    });
    return( index );
  }

  protected virtual void delete_row( int index ) {
    _list_box.remove( _list_box.get_children().nth_data( index ) );
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
