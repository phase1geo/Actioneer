using Gtk;
using Gdk;

public class ActionUploadBox : ActionBase {

  private ServerOptMenu _mb;
  private Entry         _entry;

  /* Default constructor */
  public ActionUploadBox( FileActionType type ) {

    base( type );

    if( type.pretext() != "" ) {
      var label = new Label( type.pretext() );
      pack_start( label, false, false, 0 );
    }

    _mb = new ServerOptMenu();
    _mb.activated.connect((index) => {
      if( index == 0 ) {
        var editor = new EditServer( Actioneer.appwin, null );
        editor.completed.connect((index) => {
          if( index != -1 ) {
            _mb.repopulate_menu();
            _mb.set_current_item( index + 1 );
          }
        });
      }
    });

    _entry = new Entry();
    _entry.placeholder_text = _( "Remote pathname" );
    _entry.hexpand          = true;
    _entry.hexpand_set      = true;

    pack_start( _mb,    false, false, 0 );
    pack_start( _entry, false, true,  0 );

    _mb.grab_focus();

  }

  /* Save the results off as TokenText */
  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    data.conn.server = Actioneer.servers.get_server( _mb.get_current_item() - 1 );
    data.conn.path   = _entry.text;
    return( data );
  }

  public override void set_data( FileAction data ) {
    _mb.set_current_item( Actioneer.servers.get_server_index( data.conn.server.name ) + 1 );
    _entry.text = data.conn.path;
  }

}
