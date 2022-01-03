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
    var retval = ofile.move( new_file, NONE );
    pathname   = new_file.get_path();
    return( retval );
  }

  private bool do_copy( string pathname, File new_file ) {
    var ofile  = File.new_for_path( pathname );
    return( ofile.copy( new_file, NONE ) );
  }

  public bool file_execute( ref string pathname, File new_file ) {
    switch( this ) {
      case MOVE   :  return( do_move( ref pathname, new_file ) );
      case COPY   :  return( do_copy( pathname, new_file ) );
      case RENAME :  return( do_move( ref pathname, new_file ) );
      default     :  assert_not_reached();
    }
  }

  public bool is_file_type() {
    return( (this == MOVE) || (this == COPY) || (this == RENAME) );
  }

}

public class FileAction {

  public static const string xml_node = "file-action";

  private FileActionType _type;
  private File?          _file;

  public bool   err    { get; set; default = false; }
  public string errmsg { get; set; default = ""; }

  /* Default constructor */
  public FileAction() {
    _type = FileActionType.MOVE;
    _file = null;
  }

  /* Constructor */
  public FileAction.with_filename( FileActionType type, string filename ) {
    assert( type.is_file_type() );
    _type = type;
    _file = File.new_for_path( filename );
  }

  /*
   Executes the action and returns true if it was successful.  If true is returned,
   the err and errmsg value will be updated with the error information.  If the
   pathname is changed by the action, updates the pathname value.
  */
  public bool execute( ref string pathname ) {

    if( _type.is_file_type() ) {
      try {
        return( _type.file_execute( ref pathname, _file ) );
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
