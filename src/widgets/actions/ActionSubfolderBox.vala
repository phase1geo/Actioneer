using Gtk;
using Gdk;

public class ActionSubfolderBox : ActionBase {

  private FileEntry    _entry;
  private TokenTextBox _tbox;

  /* Default constructor */
  public ActionSubfolderBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );
    pack_start( label, false, false, 0 );

    _entry = new FileEntry();
    pack_start( _entry, false, true, 0 );

    var sep = new Label( "/" );
    pack_start( sep, false, false, 0 );

    _tbox = new TokenTextBox();
    pack_start( _tbox, true, true, 0 );

  }

  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    var dir  = new TextToken.with_text( _entry.text );
    var sep  = new TextToken.with_type( TextTokenType.DIR_SEP );
    data.token_text.add_token( dir );
    data.token_text.add_token( sep );
    _tbox.get_data( data.token_text );
    return( data );
  }

  public override void set_data( FileAction data ) {
    var token = data.token_text.get_token( 0 );
    if( token.token_type == TextTokenType.TEXT ) {
      _entry.text = token.text;
      _tbox.set_data( data.token_text, 2 );
    }
  }

}
