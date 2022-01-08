public enum TextTokenType {
  TEXT,
  FILE_FULL,
  FILE_BASE,
  FILE_EXT,
  FILE_CDATE,
  FILE_MDATE,
  TODAY,
  NUM;

  public string to_string() {
    switch( this ) {
      case TEXT       :  return( "text" );
      case FILE_FULL  :  return( "file-full" );
      case FILE_BASE  :  return( "file-base" );
      case FILE_EXT   :  return( "file-ext" );
      case FILE_CDATE :  return( "file-cdate" );
      case FILE_MDATE :  return( "file-mdate" );
      case TODAY      :  return( "today" );
      default         :  assert_not_reached();
    }
  }

  public static TextTokenType parse( string val ) {
    switch( val ) {
      case "text"       :  return( TEXT );
      case "file-full"  :  return( FILE_FULL );
      case "file-base"  :  return( FILE_BASE );
      case "file-ext"   :  return( FILE_EXT );
      case "file-cdate" :  return( FILE_CDATE );
      case "file-mdate" :  return( FILE_MDATE );
      case "today"      :  return( TODAY );
      default           :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case TEXT       :  return( _( "Text" ) );
      case FILE_FULL  :  return( _( "Filename" ) );
      case FILE_BASE  :  return( _( "Basename" ) );
      case FILE_EXT   :  return( _( "Extension" ) );
      case FILE_CDATE :  return( _( "Creation Date" ) );
      case FILE_MDATE :  return( _( "Modification Date" ) );
      case TODAY      :  return( _( "Today" ) );
      default         :  assert_not_reached();
    }
  }

  public string convert( File file, string date_pattern ) {
    switch( this ) {
      case TEXT       :  return( "" );
      case FILE_FULL  :  return( Utils.file_fullname( file.get_path() ) );
      case FILE_BASE  :  return( Utils.file_name( file.get_path() ) );
      case FILE_EXT   :  return( Utils.file_extension( file.get_path() ) );
      case FILE_CDATE :  return( Utils.date_to_string( Utils.file_create_date( file.get_path() ), date_pattern ) );
      case FILE_MDATE :  return( Utils.date_to_string( Utils.file_modify_date( file.get_path() ), date_pattern ) );
      case TODAY      :  return( Utils.date_to_string( new DateTime.now(), date_pattern ) );
      default         :  assert_not_reached();
    }
  }

  public bool is_text() {
    return( this == TEXT );
  }

  public bool is_file_part() {
    return( (this == FILE_FULL) || (this == FILE_BASE) || (this == FILE_EXT) );
  }

  public bool is_date() {
    return( (this == FILE_CDATE) || (this == FILE_MDATE) || (this == TODAY) );
  }

}

public enum TextTokenModifier {
  NONE,
  LOWER,
  UPPER,
  TITLE,
  NUM;

  public string to_string() {
    switch( this ) {
      case NONE  :  return( "none" );
      case LOWER :  return( "lower" );
      case UPPER :  return( "upper" );
      case TITLE :  return( "title" );
      default    :  assert_not_reached();
    }
  }

  public static TextTokenModifier parse( string val ) {
    switch( val ) {
      case "none"  :  return( NONE );
      case "lower" :  return( LOWER );
      case "upper" :  return( UPPER );
      case "title" :  return( TITLE );
      default      :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case NONE  :  return( _( "No change" ) );
      case LOWER :  return( _( "Lowercase" ) );
      case UPPER :  return( _( "Uppercase" ) );
      case TITLE :  return( _( "Titlecase" ) );
      default    :  assert_not_reached();
    }
  }

  /* Applies the current modifier to the given string and returns the result */
  public string format( string val ) {
    switch( this ) {
      case NONE  :  return( val );
      case LOWER :  return( val.down() );
      case UPPER :  return( val.up() );
      case TITLE :  return( val.splice( 0, 0, val.slice( 0, 0 ).up() ) );
      default    :  assert_not_reached();
    }
  }

}

public class TokenText {

  public class TextToken {

    public static const string xml_node = "text-token";

    public TextTokenType     token_type { get; private set; default = TextTokenType.TEXT; }
    public string            text       { get; set; default = ""; }
    public TextTokenModifier modifier   { get; set; default = TextTokenModifier.NONE; }

    /* Default constructor */
    public TextToken() {}

    /* Constructor */
    public TextToken.with_type( TextTokenType type ) {
      assert( !type.is_text() && !type.is_date() );
      token_type = type;
    }

    /* Constructor */
    public TextToken.with_date_pattern( TextTokenType type, string pattern ) {
      assert( type.is_date() );
      token_type = type;
      text = pattern;
    }

    /* Constructor with text */
    public TextToken.with_text( string txt ) {
      text = txt;
    }

    /* Copy constructor */
    public TextToken.copy( TextToken other ) {
      token_type = other.token_type;
      text       = other.text;
    }

    /* Generates the text associated with this token */
    public string generate_text( File file ) {
      return( modifier.format( token_type.convert( file, text ) ) );
    }

    /* Saves this instance in XML format */
    public Xml.Node* save() {
      Xml.Node* node = new Xml.Node( null, xml_node );
      node->set_prop( "type", token_type.to_string() );
      node->set_prop( "text", text );
      node->set_prop( "modifier", modifier.to_string() );
      return( node );
    }

    /* Loads this instance from XML format */
    public void load( Xml.Node* node ) {
      var t = node->get_prop( "type" );
      if( t != null ) {
        token_type = TextTokenType.parse( t );
      }
      var txt = node->get_prop( "text" );
      if( txt != null ) {
        text = txt;
      }
      var mod = node->get_prop( "modifier" );
      if( mod != null ) {
        modifier = TextTokenModifier.parse( mod );
      }
    }

  }

  public static const string xml_node = "token-text";

  private List<TextToken> _tokens;

  /* Default constructor */
  public TokenText() {
    _tokens = new List<TextToken>();
  }

  /* Copy constructor */
  public TokenText.copy( TokenText other ) {
    _tokens = new List<TextToken>();
    other._tokens.foreach((token) => {
      _tokens.append( new TextToken.copy( token ) );
    });
  }

  /* Generates the text string based on the tokens */
  public string generate_text( File file ) {
    var str = "";
    _tokens.foreach((token) => {
      str += token.generate_text( file );
    });
    return( str );
  }

  /* Saves this instance in XML format */
  public Xml.Node* save() {
    Xml.Node* node = new Xml.Node( null, xml_node );
    _tokens.foreach((token) => {
      node->add_child( token.save() );
    });
    return( node );
  }

  /* Loads this instance with XML format */
  public void load( Xml.Node* node ) {
    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == TextToken.xml_node) ) {
        var token = new TextToken();
        token.load( it );
        _tokens.append( token );
      }
    }
  }

}
