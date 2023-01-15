public enum TagsMatchType {
  CONTAINS,
  CONTAINS_NOT,
  ANY,
  NONE,
  NUM;

  public string to_string() {
    switch( this ) {
      case CONTAINS     :  return( "contains" );
      case CONTAINS_NOT :  return( "contains-not" );
      case ANY          :  return( "any" );
      case NONE         :  return( "none" );
      default           :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case CONTAINS     :  return( "contain" );
      case CONTAINS_NOT :  return( "do not contain" );
      case ANY          :  return( "are set" );
      case NONE         :  return( "are empty" );
      default           :  assert_not_reached();
    }
  }

  public static TagsMatchType parse( string val ) {
    switch( val ) {
      case "contains"     :  return( CONTAINS );
      case "contains-not" :  return( CONTAINS_NOT );
      case "any"          :  return( ANY );
      case "none"         :  return( NONE );
      default             :  assert_not_reached();
    }
  }

  /* Returns true if the two strings match exactly */
  private bool contains( string[] act, string exp ) {
    for( int i=0; i<act.length; i++ ) {
      if( act[i] == exp ) {
        return( true );
      }
    }
    return( false );
  }

  private bool empty( string[] act ) {
    return( act.length == 0 );
  }

  /* Returns true if the given expected string matches the actual string according to the type */
  public bool matches( string[]? act, string exp ) {
    if( act == null ) {
      return false;
    }
    switch( this ) {
      case CONTAINS     :  return( contains( act, exp ) );
      case CONTAINS_NOT :  return( !contains( act, exp ) );
      case ANY          :  return( !empty( act ) );
      case NONE         :  return( empty( act ) );
      default           :  return( false );
    }
  }

}

public class TagsCondition {

  public TagsMatchType match_type { get; set; default = TagsMatchType.CONTAINS; }
  public string        text       { get; set; default = ""; }

  /* Default constructor */
  public TagsCondition() {}

  /* Copy constructor */
  public TagsCondition.copy( TagsCondition other ) {
    match_type = other.match_type;
    text       = other.text;
  }

  /* Returns true if the file string matches the stored type and text */
  public bool check( string[]? act ) {
    if( text == null ) return( false );
    return( match_type.matches( act, text ) );
  }

  public void save( Xml.Node* node ) {
    node->set_prop( "match_type", match_type.to_string() );
    node->set_prop( "text", text );
  }

  public void load( Xml.Node* node ) {

    var typ = node->get_prop( "match_type" );
    if( typ != null ) {
      match_type = TagsMatchType.parse( typ );
    }

    var txt = node->get_prop( "text" );
    if( txt != null ) {
      text = txt;
    }

  }

}
