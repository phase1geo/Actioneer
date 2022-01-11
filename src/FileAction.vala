public enum FileActionType {
  MOVE,
  COPY,
  RENAME,
  NUM;

  public string to_string() {
    switch( this ) {
      case MOVE   :  return( "move" );
      case COPY   :  return( "copy" );
      case RENAME :  return( "rename" );
      default     :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case MOVE   :  return( _( "Move" ) );
      case COPY   :  return( _( "Copy" ) );
      case RENAME :  return( _( "Rename" ) );
      default     :  assert_not_reached();
    }
  }

  public static FileActionType parse( string val ) {
    switch( val ) {
      case "move"   :  return( MOVE );
      case "copy"   :  return( COPY );
      case "rename" :  return( RENAME );
      default       :  assert_not_reached();
    }
  }

  private bool do_move( ref string pathname, File new_file ) {
    var ofile  = File.new_for_path( pathname );
    var nfile  = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    var retval = ofile.move( nfile, NONE );
    pathname   = nfile.get_path();
    return( retval );
  }

  private bool do_copy( string pathname, File new_file ) {
    var ofile = File.new_for_path( pathname );
    return( ofile.copy( new_file, NONE ) );
  }

  private bool do_rename( ref string pathname, TokenText token_text ) {
    var ofile  = File.new_for_path( pathname );
    var nfile  = File.new_for_path( Path.build_filename( ofile.get_path(), token_text.generate_text( ofile ) ) );
    var retval = ofile.move( nfile, NONE );
    pathname   = nfile.get_path();
    return( retval );
  }

  public bool file_execute( ref string pathname, File new_file, TokenText token_text ) {
    switch( this ) {
      case MOVE   :  return( do_move( ref pathname, new_file ) );
      case COPY   :  return( do_copy( pathname, new_file ) );
      case RENAME :  return( do_rename( ref pathname, token_text ) );
      default     :  assert_not_reached();
    }
  }

  public bool is_file_type() {
    return( (this == MOVE) || (this == COPY) || (this == RENAME) );
  }

  public bool is_tokenized() {
    return( this == RENAME );
  }

}

public class FileAction {

  public static const string xml_node = "file-action";

  private FileActionType _type;
  private File?          _file;
  private TokenText?     _token_text;

  public FileActionType action_type {
    get {
      return( _type );
    }
  }
  public File? file {
    get {
      return( _file );
    }
  }
  public TokenText? token_text {
    get {
      return( _token_text );
    }
  }

  public bool   err    { get; set; default = false; }
  public string errmsg { get; set; default = ""; }

  /* Default Constructor */
  public FileAction() {
    _type = FileActionType.MOVE;
    _file = null;
    _token_text = null;
  }

  /* Constructor */
  public FileAction.with_type( FileActionType type ) {
    _type = type;
    _file = null;
    _token_text = type.is_tokenized() ? new TokenText() : null;
  }

  /* Constructor */
  public FileAction.with_filename( FileActionType type, string filename ) {
    assert( type.is_file_type() );
    _type       = type;
    _file       = File.new_for_path( filename );
    _token_text = type.is_tokenized() ? new TokenText() : null;
  }

  /* Copy constructor */
  public FileAction.copy( FileAction other ) {
    _type       = other._type;
    _file       = File.new_for_path( other._file.get_path() );
    _token_text = _type.is_tokenized() ? new TokenText.copy( other._token_text ) : null;
  }

  /*
   Executes the action and returns true if it was successful.  If true is returned,
   the err and errmsg value will be updated with the error information.  If the
   pathname is changed by the action, updates the pathname value.
  */
  public bool execute( ref string pathname ) {

    if( _type.is_file_type() ) {
      try {
        return( _type.file_execute( ref pathname, _file, _token_text ) );
      } catch( Error e ) {
        err    = true;
        errmsg = e.message;
      }
    }

    return( false );

  }

  /* Save this instance in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type", _type.to_string() );
    node->set_prop( "file", _file.get_path() );

    return( node );

  }

  /* Loads the XML formatted version of this instance into memory */
  public void load( Xml.Node* node ) {

    var type = node->get_prop( "type" );
    if( type != null ) {
      _type = FileActionType.parse( type );
    }

    var file = node->get_prop( "file" );
    if( file != null ) {
      _file = File.new_for_path( file );
    }

  }

}
