public enum FileActionType {
  MOVE,
  COPY,
  RENAME,
  ALIAS,
  TRASH,
  NOTIFY,
  RUN_SCRIPT,
  NUM;

  public string to_string() {
    switch( this ) {
      case MOVE       :  return( "move" );
      case COPY       :  return( "copy" );
      case RENAME     :  return( "rename" );
      case ALIAS      :  return( "alias" );
      case TRASH      :  return( "trash" );
      case NOTIFY     :  return( "notify" );
      case RUN_SCRIPT :  return( "run-script" );
      default         :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case MOVE       :  return( _( "Move" ) );
      case COPY       :  return( _( "Copy" ) );
      case RENAME     :  return( _( "Rename" ) );
      case ALIAS      :  return( _( "Alias" ) );
      case TRASH      :  return( _( "Trash" ) );
      case NOTIFY     :  return( _( "Notify" ) );
      case RUN_SCRIPT :  return( _( "Run Script" ) );
      default         :  assert_not_reached();
    }
  }

  public string pretext() {
    switch( this ) {
      case MOVE       :  return( _( "to folder" ) );
      case COPY       :  return( _( "to folder" ) );
      case RENAME     :  return( _( "file as" ) );
      case ALIAS      :  return( _( "from folder" ) );
      case TRASH      :  return( _( "file" ) );
      case NOTIFY     :  return( _( "with message" ) );
      case RUN_SCRIPT :  return( "" );
      default         :  assert_not_reached();
    }
  }

  public static FileActionType parse( string val ) {
    switch( val ) {
      case "move"       :  return( MOVE );
      case "copy"       :  return( COPY );
      case "rename"     :  return( RENAME );
      case "alias"      :  return( ALIAS );
      case "trash"      :  return( TRASH );
      case "notify"     :  return( NOTIFY );
      case "run-script" :  return( RUN_SCRIPT );
      default           :  assert_not_reached();
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

  private bool do_alias( string pathname, File new_file ) {
    var ofile = File.new_for_path( pathname );
    var nfile = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    return( nfile.make_symbolic_link( ofile.get_path() ) );
  }

  private bool do_trash( string pathname ) {
    var ofile = File.new_for_path( pathname );
    return( ofile.trash() );
  }

  private bool do_notify( MainWindow win, string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var msg   = token_text.generate_text( ofile );
    win.notification( _( "Actioneer" ), msg );
    return( true );
  }

  /* Executes a script determined by token_text */
  private bool do_run_script( string pathname, TokenText token_text ) {
    var ofile  = File.new_for_path( pathname );
    var script = token_text.generate_text( ofile );
    return( Process.spawn_command_line_async( script ) );
  }

  public bool file_execute( MainWindow win, ref string pathname, File? new_file, TokenText? token_text ) {

    switch( this ) {
      case MOVE       :  return( do_move( ref pathname, new_file ) );
      case COPY       :  return( do_copy( pathname, new_file ) );
      case RENAME     :  return( do_rename( ref pathname, token_text ) );
      case ALIAS      :  return( do_alias( pathname, new_file ) );
      case TRASH      :  return( do_trash( pathname ) );
      case NOTIFY     :  return( do_notify( win, pathname, token_text ) );
      case RUN_SCRIPT :  return( do_run_script( pathname, token_text ) );
      default         :  assert_not_reached();
    }
  }

  public bool is_file_type() {
    switch( this ) {
      case MOVE       :
      case COPY       :
      case RENAME     :
      case ALIAS      :
      case TRASH      :
      case NOTIFY     :
      case RUN_SCRIPT :  return( true );
      default         :  return( false );
    }
  }

  public bool is_tokenized() {
    return( (this == RENAME) || (this == NOTIFY) || (this == RUN_SCRIPT) );
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
    _type       = FileActionType.MOVE;
    _file       = null;
    _token_text = null;
  }

  /* Constructor */
  public FileAction.with_type( FileActionType type ) {
    _type       = type;
    _file       = null;
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
    _file       = (other._file       == null) ? null : File.new_for_path( other._file.get_path() );
    _token_text = (other._token_text == null) ? null : new TokenText.copy( other._token_text );
  }

  /*
   Executes the action and returns true if it was successful.  If true is returned,
   the err and errmsg value will be updated with the error information.  If the
   pathname is changed by the action, updates the pathname value.
  */
  public bool execute( MainWindow win, ref string pathname ) {

    if( _type.is_file_type() ) {
      try {
        return( _type.file_execute( win, ref pathname, _file, _token_text ) );
      } catch( SpawnError e ) {
        err    = true;
        errmsg = e.message;
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

    if( _file != null ) {
      node->set_prop( "file", _file.get_path() );
    }

    if( _token_text != null ) {
      node->add_child( _token_text.save() );
    }

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

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == TokenText.xml_node) ) {
        _token_text = new TokenText();
        _token_text.load( it );
      }
    }

  }

}
