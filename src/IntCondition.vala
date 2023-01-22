public enum IntMatchType {
  EQ,
  NE,
  LT,
  GT,
  LTE,
  GTE,
  NUM;

  public string to_string() {
    switch( this ) {
      case EQ  :  return( "eq" );
      case NE  :  return( "ne" );
      case LT  :  return( "lt" );
      case GT  :  return( "gt" );
      case LTE :  return( "lte" );
      case GTE :  return( "gte" );
      default  :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case EQ  :  return( "equals" );
      case NE  :  return( "does not equal" );
      case LT  :  return( "is less than" );
      case GT  :  return( "is greater than" );
      case LTE :  return( "is less than or equals" );
      case GTE :  return( "is greater than or equals" );
      default  :  assert_not_reached();
    }
  }

  public static IntMatchType parse( string val ) {
    switch( val ) {
      case "eq"  :  return( EQ );
      case "ne"  :  return( NE );
      case "lt"  :  return( LT );
      case "gt"  :  return( GT );
      case "lte" :  return( LTE );
      case "gte" :  return( GTE );
      default    :  assert_not_reached();
    }
  }

  /* Returns true if the two file sizes are equal */
  private bool equals( int act, int exp ) {
    return( act == exp );
  }

  /* Returns true if the actual string starts with the expected string */
  private bool less_than( int act, int exp ) {
    return( act < exp );
  }

  /* Returns true if the given expected string matches the actual string according to the type */
  public bool matches( int act, int exp ) {
    switch( this ) {
      case EQ  :  return( equals( act, exp ) );
      case NE  :  return( !equals( act, exp ) );
      case LT  :  return( less_than( act, exp ) );
      case GT  :  return( !less_than( act, exp ) && !equals( act, exp ) );
      case LTE :  return( less_than( act, exp ) || equals( act, exp ) );
      case GTE :  return( !less_than( act, exp ) || equals( act, exp ) );
      default  :  return( false );
    }
  }

}

public class IntCondition {

  public IntMatchType match_type { get; set; default = IntMatchType.EQ; }
  public int          num        { get; set; default = 0; }

  /* Default constructor */
  public IntCondition() {}

  /* Copy constructor */
  public IntCondition.copy( IntCondition other ) {
    match_type = other.match_type;
    num        = other.num;
  }

  /* Returns true if the file string matches the stored type and text */
  public bool check( int act ) {
    return( match_type.matches( act, num ) );
  }

  public void save( Xml.Node* node ) {
    node->set_prop( "match_type", match_type.to_string() );
    node->set_prop( "num", num.to_string() );
  }

  public void load( Xml.Node* node ) {

    var typ = node->get_prop( "match_type" );
    if( typ != null ) {
      match_type = IntMatchType.parse( typ );
    }

    var n = node->get_prop( "num" );
    if( n != null ) {
      num = int.parse( n );
    }

  }

}
