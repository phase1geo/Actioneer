public enum FileActionType {
  MOVE,
  RENAME,
  NUM;

  public string to_string() {
    switch( this ) {
      case MOVE   :  return( "move" );
      case RENAME :  return( "rename" );
      default     :  assert_not_reached();
    }
  }

  public FileActionType parse( string val ) {
    switch( val ) {
      case "move"   :  return( MOVE );
      case "rename" :  return( RENAME );
      default       :  assert_not_reached();
    }
  }

}

public class FileAction {

  public static string xml_node = "file-action";

  private FileActionType _type;

  public bool   err    { get; set; default = false; }
  public string errmsg { get; set; default = ""; }

  public FileActionType type {
    get {
      return( _type );
    }
    set {
      if( _type != value ) {
        _type = value;
      }
    }
  }

  /* Default constructor */
  public FileAction() {
    _type = FileTypeAction.MOVE;
  }

  /*
   Executes the action and returns true if it was successful.  If true is returned,
   the err and errmsg value will be updated with the error information.  If the
   pathname is changed by the action, updates the pathname value.
  */
  public bool execute( ref string pathname ) {
    return( false );
  }

  /* Save this instance in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type", _type );

    return( null );

  }

  /* Loads the XML formatted version of this instance into memory */
  public void load( Xml.Node* node ) {

    var type = node->get_prop( "type" );
    if( type != null ) {
      _type   = FileActionType.parse( type );
      _action = _type.action();
    }

  }

}
