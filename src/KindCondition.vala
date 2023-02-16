public enum FileKind {
  FILE,
  FOLDER,
  ALIAS,
  HIDDEN,
  ANY,
  NUM;

  public string to_string() {
    switch( this ) {
      case FILE   :  return( "file" );
      case FOLDER :  return( "folder" );
      case ALIAS  :  return( "alias" );
      case HIDDEN :  return( "hidden" );
      case ANY    :  return( "any" );
      default     :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case FILE   :  return( _( "file" ) );
      case FOLDER :  return( _( "folder" ) );
      case ALIAS  :  return( _( "alias" ) );
      case HIDDEN :  return( _( "hidden" ) );
      case ANY    :  return( _( "any" ) );
      default     :  assert_not_reached();
    }
  }

  public static FileKind parse( string val ) {
    switch( val ) {
      case "file"   :  return( FILE );
      case "folder" :  return( FOLDER );
      case "alias"  :  return( ALIAS );
      case "hidden" :  return( HIDDEN );
      case "any"    :  return( ANY );
      default       :  assert_not_reached();
    }
  }

}

public enum KindMatchType {
  IS,
  IS_NOT,
  NUM;

  public string to_string() {
    switch( this ) {
      case IS     :  return( "is" );
      case IS_NOT :  return( "is-not" );
      default     :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case IS     :  return( "is" );
      case IS_NOT :  return( "is not" );
      default     :  assert_not_reached();
    }
  }

  public static KindMatchType parse( string val ) {
    switch( val ) {
      case "is"     :  return( IS );
      case "is-not" :  return( IS_NOT );
      default       :  assert_not_reached();
    }
  }

  /* Returns true if the given expected kind matches the actual kind according to the type */
  public bool matches( FileKind act, FileKind exp ) {
    switch( this ) {
      case IS     :  return( act == exp );
      case IS_NOT :  return( act != exp );
      default     :  return( false );
    }
  }

}

public class KindCondition {

  public KindMatchType match_type { get; set; default = KindMatchType.IS; }
  public FileKind      kind       { get; set; default = FileKind.FILE; }

  /* Default constructor */
  public KindCondition() {}

  /* Copy constructor */
  public KindCondition.copy( KindCondition other ) {
    match_type = other.match_type;
    kind       = other.kind; 
  }

  /* Returns true if the file string matches the stored type and text */
  public bool check( FileKind act ) {
    return( (kind == FileKind.ANY) || match_type.matches( act, kind ) );
  }

  public bool matches( string value ) {
    return( kind.label().contains( value ) );
  }

  public void save( Xml.Node* node ) {
    node->set_prop( "match_type", match_type.to_string() );
    node->set_prop( "kind", kind.to_string() );
  }

  public void load( Xml.Node* node ) {

    var typ = node->get_prop( "match_type" );
    if( typ != null ) {
      match_type = KindMatchType.parse( typ );
    }

    var k = node->get_prop( "kind" );
    if( k != null ) {
      kind = FileKind.parse( k );
    }

  }

}
