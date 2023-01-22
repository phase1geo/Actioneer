using Gtk;

public class ActionCompressBox : ActionBase {

  private CompFormatOptMenu _format_mb;
  private CompLevelOptMenu  _level_mb;

  /* Default constructor */
  public ActionCompressBox( FileActionType type ) {

    base( type );

    var label     = new Label( type.pretext() );
    var level_lbl = new Label( _( "with compression level" ) );

    _format_mb = new CompFormatOptMenu();
    _level_mb  = new CompLevelOptMenu();

    pack_start( label,      false, false, 0 );
    pack_start( _format_mb, false, false, 0 );
    pack_start( level_lbl,  false, false, 0 );
    pack_start( _level_mb,  false, false, 0 );

    _level_mb.set_current_item( 9 );

  }

  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    data.compress.type  = _format_mb.get_zlib_type();
    data.compress.level = _level_mb.get_current_item(); 
    return( data );
  }

  public override void set_data( FileAction data ) {
    _format_mb.set_from_type( data.compress.type );
    _level_mb.set_current_item( data.compress.level );
  }

}
