using Gtk;

public class ActionEmptyBox : ActionBase {

  /* Default constructor */
  public ActionEmptyBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );

    pack_start( label,  false, false, 0 );

  }

  public override FileAction get_data() {
    return( new FileAction.with_type( _type ) );
  }

  public override void set_data( FileAction data ) {
    // Do nothing
  }

}
