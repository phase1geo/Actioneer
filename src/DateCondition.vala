public enum TimeType {
  NOW,
  MINUTE,
  HOUR,
  DAY,
  WEEK,
  MONTH,
  YEAR,
  NUM;

  public string to_string() {
    switch( this ) {
      case NOW    :  return( "now" );
      case MINUTE :  return( "minute" );
      case HOUR   :  return( "hour" );
      case DAY    :  return( "day" );
      case WEEK   :  return( "week" );
      case MONTH  :  return( "month" );
      case YEAR   :  return( "year" );
      default     :  assert_not_reached();
    }
  }

  public static TimeType parse( string val ) {
    switch( val ) {
      case "now"    :  return( NOW );
      case "minute" :  return( MINUTE );
      case "hour"   :  return( HOUR );
      case "day"    :  return( DAY );
      case "week"   :  return( WEEK );
      case "month"  :  return( MONTH );
      case "year"   :  return( YEAR );
      default       :  assert_not_reached();
    }
  }

  public DateTime from_date( DateTime now, int num ) {
    switch( this ) {
      case MINUTE :  return( now.add_minutes( num ) );
      case HOUR   :  return( now.add_hours( num ) );
      case DAY    :  return( now.add_days( num ) );
      case WEEK   :  return( now.add_days( (num * 7) ) );
      case MONTH  :  return( now.add_months( num ) );
      case YEAR   :  return( now.add_years( num ) );
      default     :  return( now );
    }
  }

}

public enum DateMatchType {
  IS,
  IS_NOT,
  BEFORE,
  AFTER,
  LAST,
  LAST_NOT,
  NEXT,
  NEXT_NOT,
  NUM;

  public string to_string() {
    switch( this ) {
      case IS       :  return( "is" );
      case IS_NOT   :  return( "is-not" );
      case BEFORE   :  return( "before" );
      case AFTER    :  return( "after" );
      case LAST     :  return( "last" );
      case LAST_NOT :  return( "last-not" );
      case NEXT     :  return( "next" );
      case NEXT_NOT :  return( "next-not" );
      default       :  assert_not_reached();
    }
  }

  public static DateMatchType parse( string val ) {
    switch( val ) {
      case "is"       :  return( IS );
      case "is-not"   :  return( IS_NOT );
      case "before"   :  return( BEFORE );
      case "after"    :  return( AFTER );
      case "last"     :  return( LAST );
      case "last-not" :  return( LAST_NOT );
      case "next"     :  return( NEXT );
      case "next-not" :  return( NEXT_NOT );
      default         :  assert_not_reached();
    }
  }

  private bool is_matches( DateTime act, DateTime exp ) {
    return( act.compare( exp ) == 0 );
  }

  private bool before_matches( DateTime act, DateTime exp ) {
    return( act.compare( exp ) < 0 );
  }

  private bool after_matches( DateTime act, DateTime exp ) {
    return( act.compare( exp ) > 0 );
  }

  private bool last_matches( DateTime act, int num, TimeType amount ) {
    var now  = DateTime.now();
    var then = amount.from_date( now, (0 - num) ); 
    return( (act.compare( now ) != 1) && (act.compare( then ) != -1) );
  }

  private bool next_matches( DateTime act, int num, TimeType amount ) {
    var now  = DateTime.now();
    var then = amount.from_date( now, num ); 
    return( (act.compare( now ) != -1) && (act.compare( then ) != 1) );
  }

  public bool matches( Date act, Date exp, int num, TimeType amount ) {
    switch( this ) {
      case IS       :  return( is_matches( act, exp ) );
      case IS_NOT   :  return( !is_matches( act, exp ) );
      case BEFORE   :  return( before_matches( act, exp ) );
      case AFTER    :  return( after_matches( act, exp ) );
      case LAST     :  return( last_matches( act, num, amount ) );
      case LAST_NOT :  return( !last_matches( act, num, amount ) );
      case NEXT     :  return( next_matches( act, num, amount ) );
      case NEXT_NOT :  return( !next_matches( act, num, amount ) );
      default       :  return( false );
    }
  }

  public void save( Xml.Node* node, DateTime exp, int num, TimeType amount ) {
    node->set_prop( "type", to_string() );
    switch( this ) {
      case IS     :
      case IS_NOT :
      case BEFORE :
      case AFTER  :
        node->set_prop( "date-time", exp.to_string() );
        break;
      case LAST     :
      case LAST_NOT :
      case NEXT     :
      case NEXT_NOT :
        node->set_prop( "num", num.to_string() );
        node->set_prop( "amount", amount.to_string() );
        break;
    }
  }

  public void load( Xml.Node* node, ref DateTime exp, ref int num, ref TimeType amount ) {
    var t = node->get_prop( "type" );
    if( t != null ) {
      this = parse( t );
      switch( this ) {
        case IS     :
        case IS_NOT :
        case BEFORE :
        case AFTER  :
          var dt = node->get_prop( "date-time" );
          if( dt != null ) {
            exp = DateTime.from_iso8601( dt, null );
          }
          break;
        case LAST     :
        case LAST_NOT :
        case NEXT     :
        case NEXT_NOT :
          var n = node->get_prop( "num" );
          if( n != null ) {
            num = int.parse( n );
          }
          var amt = node->get_prop( "amount" );
          if( amt != null ) {
            amount = TimeType.parse( amt );
          }
          break;
      }
    }
  }

}

public class DateCondition {

  public DateMatchType type      { get; set; default = NUM; }
  public DateTime      exp       { get; set; default = DateTime.now(); }
  public int           num       { get; set; default = 0; }
  public TimeType      time_type { get; set; default = TimeType.DAY; }

  /* Default constructor */
  public DateCondition() {}

  public bool check( Date date ) {
    return( type.matches( date, exp, num, time_type ) );
  }

  public void save( Xml.Node* node ) {
    type.save( node, exp, num, time_type );
  }

  public void load( Xml.Node* node ) {
    type.load( node, ref exp, ref num, ref time_type );
  }

}
