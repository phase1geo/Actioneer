using Gtk;
using Gdk;

public class ActionTextBox : ActionBase {

  private Box      _tbox;
  private Revealer _add_reveal;
  private Entry    _entry;

  /* Default constructor */
  public ActionTextBox( FileActionType type ) {

    base( type );

    if( type.pretext() != "" ) {
      var label = new Label( type.pretext() );
      pack_start( label, false, false, 0 );
    }

    _entry = new Entry();
    _entry.placeholder_text = _( "Enter text, %f will be replaced with the filename" );
    _entry.hexpand          = true;
    _entry.hexpand_set      = true;

    pack_start( _entry, false, true, 0 );

    _entry.grab_focus();

  }

  /* Save the results off as TokenText */
  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    var strs = _entry.text.split( "%%f" );
    for( int i=0; i<strs.length; i++ ) {
      var token = new TextToken.with_text( strs[i] );
      data.token_text.add_token( token );
      if( (i + 1) < strs.length ) {
        token = new TextToken.with_type( TextTokenType.FILE_FULL );
        data.token_text.add_token( token );
      }
    }
    return( data );
  }

  public override void set_data( FileAction data ) {
    var text = "";
    for( int i=0; i<data.token_text.num_tokens(); i++ ) {
      var token = data.token_text.get_token( i );
      switch( token.token_type ) {
        case TextTokenType.TEXT      :  text += token.text;  break;
        case TextTokenType.FILE_FULL :  text += "%%f";       break;
        default                      :  assert_not_reached();
      }
    }
    _entry.text = text;
  }

}
