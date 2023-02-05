using Gtk;

public class ActionConvertBox : ActionBase {

  private ConvertOptMenu _mb;

  /* Default constructor */
  public ActionConvertBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );

    _mb = new ConvertOptMenu();

    pack_start( label, false, false, 0 );
    pack_start( _mb,   false, false, 0 );

    _mb.set_current_item( (int)ImagerFormat.JPG );

  }

  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    var img  = (ImagerConverter)data.imager;
    img.format = (ImagerFormat)_mb.get_current_item();
    return( data );
  }

  public override void set_data( FileAction data ) {
    var img = (ImagerConverter)data.imager;
    _mb.set_current_item( (int)img.format );
  }

}
