public enum SizeMatchType {
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

  public static SizeMatchType parse( string val ) {
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
  private bool equals( int64 act, int64 exp ) {
    return( act == exp );
  }

  /* Returns true if the actual string starts with the expected string */
  private bool less_than( int64 act, int64 exp ) {
    return( act < exp );
  }

  /* Returns true if the given expected string matches the actual string according to the type */
  public bool matches( int64 act, int64 exp ) {
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

public enum SizeType {
  BYTES,
  KBYTES,
  MBYTES,
  GBYTES,
  TBYTES,
  NUM;

  public string to_string() {
    switch( this ) {
      case BYTES  :  return( "B" );
      case KBYTES :  return( "KB" );
      case MBYTES :  return( "MB" );
      case GBYTES :  return( "GB" );
      case TBYTES :  return( "TB" );
      default     :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case BYTES  :  return( _( "byte(s)" ) );
      case KBYTES :  return( _( "kilobyte(s)" ) );
      case MBYTES :  return( _( "megabyte(s)" ) );
      case GBYTES :  return( _( "gigabyte(s)" ) );
      case TBYTES :  return( _( "terabyte(s)" ) );
      default     :  assert_not_reached();
    }
  }

  public static SizeType parse( string val ) {
    switch( val ) {
      case "B"  :  return( BYTES );
      case "KB" :  return( KBYTES );
      case "MB" :  return( MBYTES );
      case "GB" :  return( GBYTES );
      case "TB" :  return( TBYTES );
      default   :  assert_not_reached();
    }
  }

  public int64 get_bytes( int64 val ) {
    switch( this ) {
      case BYTES  :  return( val );
      case KBYTES :  return( val * (int64)1000 );
      case MBYTES :  return( val * (int64)1000000 );
      case GBYTES :  return( val * (int64)1000000000 );
      case TBYTES :  return( val * (int64)1000000000000 );
      default     :  assert_not_reached();
    }
  }

  public int64 get_size( int64 bytes ) {
    switch( this ) {
      case BYTES  :  return( bytes );
      case KBYTES :  return( bytes / (int64)1000 );
      case MBYTES :  return( bytes / (int64)1000000 );
      case GBYTES :  return( bytes / (int64)1000000000 );
      case TBYTES :  return( bytes / (int64)1000000000000 );
      default     :  assert_not_reached();
    }
  }

}

public class SizeCondition {

  public SizeMatchType match_type { get; set; default = SizeMatchType.EQ; }
  public int64         num        { get; set; default = 0; }
  public SizeType      size       { get; set; default = SizeType.MBYTES; }

  /* Default constructor */
  public SizeCondition() {}

  /* Copy constructor */
  public SizeCondition.copy( SizeCondition other ) {
    match_type = other.match_type;
    num        = other.num;
    size       = other.size;
  }

  /* Returns true if the file string matches the stored type and text */
  public bool check( int64 act_bytes ) {
    var exp_bytes = size.get_bytes( num );
    return( match_type.matches( size.get_size( act_bytes ), size.get_size( exp_bytes ) ) );
  }

  public bool matches( PatternSpec pattern ) {
    return( pattern.match_string( num.to_string() ) ||
            pattern.match_string( size.label().down() ) );
  }

  public void save( Xml.Node* node ) {
    node->set_prop( "match_type", match_type.to_string() );
    node->set_prop( "num", num.to_string() );
    node->set_prop( "size", size.to_string() );
  }

  public void load( Xml.Node* node ) {

    var typ = node->get_prop( "match_type" );
    if( typ != null ) {
      match_type = SizeMatchType.parse( typ );
    }

    var n = node->get_prop( "num" );
    if( n != null ) {
      num = int64.parse( n );
    }

    var sz = node->get_prop( "size" );
    if( sz != null ) {
      size = SizeType.parse( sz );
    }

  }

}
