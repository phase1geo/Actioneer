using Gtk;
using Gdk;

public class ActionRenameBox : ActionInterface, Box {

  private TextView       _text;
  private FileActionType _type;
  private Gtk.Menu       _menu;

  /* Default constructor */
  public ActionRenameBox( FileActionType type ) {

    Object( orientation: Orientation.HORIZONTAL, spacing: 10 );

    _type = type;

    _text = new TextView();
    _text.hexpand     = true;
    _text.hexpand_set = true;
    _text.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_SECONDARY ) {
        _menu.popup_at_pointer( e );
      }
      return( true );
    });

    var tag = _text.buffer.create_tag( "token",
                             "background", "light blue",
                             "background_set", true,
                             "editable", false,
                             "editable_set", true );

    tag.event.connect((obj, e, it) => {
      if( e.type == EventType.BUTTON_PRESS ) {
        stdout.printf( "%s!\n".printf( e.type.to_string() ) );
      }
      return( true );
    });

    /* Create default */
    insert_token( TextTokenType.FILE_BASE );
    _text.buffer.insert_at_cursor( ".", ".".length );
    insert_token( TextTokenType.FILE_EXT );

    /* Create the token menu */
    _menu = new Gtk.Menu();
    for( int i=0; i<TextTokenType.NUM; i++ ) {
      var token_type = (TextTokenType)i;
      var item = new Gtk.MenuItem.with_label( token_type.label() );
      item.activate.connect(() => {
        insert_token( token_type );
      });
      _menu.add( item );
    }
    _menu.show_all();

    pack_start( _text, true, true, 0 );

  }

  /* Inserts the given token */
  private void insert_token( TextTokenType type ) {
    TextIter cursor;
    var label  = " " + type.label() + " ";
    _text.buffer.get_iter_at_mark( out cursor, _text.buffer.get_insert() );
    _text.buffer.insert_with_tags_by_name( ref cursor, label, label.length, "token" );
  }

  public FileAction get_data() {
    var data = new FileAction.with_filename( _type, "foobar" /* _text.text */ );
    return( data );
  }

  public void set_data( FileAction data ) {
    // _text.text = date.text;
  }

}
