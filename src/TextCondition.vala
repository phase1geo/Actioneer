public enum TextMatchType {
  IS,
  IS_NOT,
  CONTAINS,
  CONTAINS_NOT,
  STARTS_WITH,
  ENDS_WITH,
  MATCHES_PATTERN,
  NUM;

  public string to_string() {
    switch( this ) {
      case IS              :  return( "is" );
      case IS_NOT          :  return( "is-not" );
      case CONTAINS        :  return( "contains" );
      case CONTAINS_NOT    :  return( "contains-not" );
      case STARTS_WITH     :  return( "starts-with" );
      case ENDS_WITH       :  return( "ends-with" );
      case MATCHES_PATTERN :  return( "matches-pattern" );
      default              :  assert_not_reached();
    }
  }

  public static TextMatchType parse( string val ) {
    switch( val ) {
      case "is"              :  return( IS );
      case "is-not"          :  return( IS_NOT );
      case "contains"        :  return( CONTAINS );
      case "contains-not"    :  return( CONTAINS_NOT );
      case "starts-with"     :  return( STARTS_WITH );
      case "ends-with"       :  return( ENDS_WITH );
      case "matches-pattern" :  return( MATCHES_PATTERN );
      default                :  assert_not_reached();
    }
  }

  /* Returns true if the two strings match exactly */
  private bool is_matches( string act, string exp ) {
    return( act == exp );
  }

  /* Returns true if the actual string contains the expected string */
  private bool contains( string act, string exp ) {
    return( act.contains( exp ) );
  }

  /* Returns true if the actual string starts with the expected string */
  private bool starts_with( string act, string exp ) {
    return( act.has_prefix( exp ) );
  }

  /* Returns true if the actual string ends with the expected string */
  private bool ends_with( string act, string exp ) {
    return( act.has_suffix( exp ) );
  }

  /* Returns true if the actual string matches the regular expression defined by pattern */
  private bool matches_pattern( string act, string pattern ) {
    return( Regex.match_simple( pattern, act ) );
  }

  /* Returns true if the given expected string matches the actual string according to the type */
  public bool matches( string act, string exp ) {
    switch( this ) {
      case IS              :  return( is_matches( act, exp ) );
      case IS_NOT          :  return( !is_matches( act, exp ) );
      case CONTAINS        :  return( contains( act, exp ) );
      case CONTAINS_NOT    :  return( !contains( act, exp ) );
      case STARTS_WITH     :  return( starts_with( act, exp ) );
      case ENDS_WITH       :  return( ends_with( act, exp ) );
      case MATCHES_PATTERN :  return( matches_pattern( act, exp ) );
      default              :  return( false );
    }
  }

}

public class TextCondition {

  public TextMatchType match_type { get; set; default = TextMatchType.IS; }
  public string        text       { get; set; default = ""; }

  /* Default constructor */
  public TextCondition() {}

  /* Returns true if the file string matches the stored type and text */
  public bool check( string act ) {
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
      match_type = TextMatchType.parse( typ );
    }

    var txt = node->get_prop( "text" );
    if( txt != null ) {
      text = txt;
    }

  }

}
