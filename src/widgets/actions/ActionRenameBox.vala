using Gtk;
using Gdk;

public class ActionRenameBox : ActionBase {

  private TokenTextBox _tbox;

  /* Default constructor */
  public ActionRenameBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );
    pack_start( label, false, false, 0 );

    _tbox = new TokenTextBox();
    pack_start( _tbox, true, true, 0 );

    /* Create default tokens */
    _tbox.insert_token( 0, TextTokenType.FILE_BASE, null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
    _tbox.insert_token( 1, TextTokenType.TEXT,      ".",  TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
    _tbox.insert_token( 2, TextTokenType.FILE_EXT,  null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );

  }

  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    _tbox.get_data( data.token_text );
    return( data );
  }

  public override void set_data( FileAction data ) {
    _tbox.set_data( data.token_text );
  }

}
