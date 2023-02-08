using Gtk;
using Gdk;

public class ActionOpenBox : ActionBase {

  private OpenOptMenu _mb;

  /* Default constructor */
  public ActionOpenBox( FileActionType type ) {

    base( type );

    if( type.pretext() != "" ) {
      var label = new Label( type.pretext() );
      pack_start( label, false, false, 0 );
    }

    _mb = new OpenOptMenu();

    pack_start( _mb, false, false, 0 );
    show_all();

  }

  /* Save the results off as TokenText */
  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    data.opener = _mb.get_app_info();
    return( data );
  }

  public override void set_data( FileAction data ) {
    _mb.set_app_info( data.opener );
  }

}
