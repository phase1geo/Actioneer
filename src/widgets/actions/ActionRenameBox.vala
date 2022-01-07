using Gtk;

public class ActionRenameBox : ActionInterface, Box {

  private TextView       _text;
  private FileActionType _type;

  /* Default constructor */
  public ActionRenameBox( FileActionType type ) {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

    _type = type;

    TextIter it;
    int y, height;

    _text = new TextView();
    _text.buffer.get_iter_at_offset( out it, 0 );
    _text.get_line_yrange( it, out y, out height );
    _text.height_request = height;

    stdout.printf( "height: %d\n", height );

    pack_start( _text, false, true, 0 );

  }

  public FileAction get_data() {
    var data = new FileAction.with_filename( _type, "foobar" /* _text.text */ );
    return( data );
  }

  public void set_data( FileAction data ) {
    // _text.text = date.text;
  }

}
