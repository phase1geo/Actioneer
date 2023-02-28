using Gtk;

public class ActionFileBox : ActionBase {

  private FileEntry _entry;

  /* Default constructor */
  public ActionFileBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );

    _entry = new FileEntry();

    pack_start( label,  false, false, 0 );
    pack_start( _entry, false, true,  0 );

    _entry.grab_focus();

  }

  public override FileAction get_data() {
    var data = new FileAction.with_filename( _type, _entry.text );
    return( data );
  }

  public override void set_data( FileAction data ) {
    _entry.text = data.file.get_path();
  }

}
