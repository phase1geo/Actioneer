using Gtk;

public class ActionFileBox : ActionInterface, Box {

  private Entry          _entry;
  private FileActionType _type;

  /* Default constructor */
  public ActionFileBox( FileActionType type ) {

    Object( orientation: Orientation.HORIZONTAL, spacing: 10 );

    _type = type;

    _entry = new Entry();
    _entry.can_focus        = false;
    _entry.placeholder_text = _( "Select a folder" );
    _entry.hexpand          = true;
    _entry.hexpand_set      = true;

    var button = new Button.from_icon_name( "document-open-symbolic", IconSize.SMALL_TOOLBAR );
    button.set_tooltip_text( _( "Browse filesystem" ) );
    button.clicked.connect( open_file );

    pack_start( _entry, false, true,  0 );
    pack_end(   button, false, false, 0 );

  }

  private void open_file() {
    var dialog = new FileChooserNative( _( "Choose Directory" ), Actioneer.appwin, FileChooserAction.SELECT_FOLDER, _( "Choose" ), _( "Cancel" ) );
    if( dialog.run() == ResponseType.ACCEPT ) {
      _entry.text = dialog.get_filename();
    }
  }

  public FileAction get_data() {
    var data = new FileAction.with_filename( _type, _entry.text );
    return( data );
  }

  public void set_data( FileAction data ) {
    _entry.text = data.file.get_path();
  }

}
