public enum TextTokenType {
  TEXT,
  FILE_FULL,
  FILE_BASE,
  FILE_EXT,
  FILE_CDATE,
  FILE_MDATE,
  TODAY,
  FILE_OWNER,
  FILE_GROUP,
  UNIQUE_ID,
  IMAGE_WIDTH,
  IMAGE_HEIGHT,
  NUM;

  public string to_string() {
    switch( this ) {
      case TEXT         :  return( "text" );
      case FILE_FULL    :  return( "file-full" );
      case FILE_BASE    :  return( "file-base" );
      case FILE_EXT     :  return( "file-ext" );
      case FILE_CDATE   :  return( "file-cdate" );
      case FILE_MDATE   :  return( "file-mdate" );
      case TODAY        :  return( "today" );
      case FILE_OWNER   :  return( "file-owner" );
      case FILE_GROUP   :  return( "file-group" );
      case UNIQUE_ID    :  return( "unique-id" );
      case IMAGE_WIDTH  :  return( "img-width" );
      case IMAGE_HEIGHT :  return( "img-height" );
      default           :  assert_not_reached();
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
      case "file-owner" :  return( FILE_OWNER );
      case "file-group" :  return( FILE_GROUP );
      case "unique-id"  :  return( UNIQUE_ID );
      case "img-width"  :  return( IMAGE_WIDTH );
      case "img-height" :  return( IMAGE_HEIGHT );
      default           :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case TEXT         :  return( _( "Text" ) );
      case FILE_FULL    :  return( _( "Filename" ) );
      case FILE_BASE    :  return( _( "Basename" ) );
      case FILE_EXT     :  return( _( "Extension" ) );
      case FILE_CDATE   :  return( _( "Creation Date" ) );
      case FILE_MDATE   :  return( _( "Modification Date" ) );
      case TODAY        :  return( _( "Today" ) );
      case FILE_OWNER   :  return( _( "File Owner" ) );
      case FILE_GROUP   :  return( _( "File Group" ) );
      case UNIQUE_ID    :  return( _( "Unique ID" ) );
      case IMAGE_WIDTH  :  return( _( "Image Width" ) );
      case IMAGE_HEIGHT :  return( _( "Image Height" ) );
      default           :  assert_not_reached();
    }
  }

  public string convert( File file, string date_pattern ) {
    switch( this ) {
      case TEXT         :  return( date_pattern );
      case FILE_FULL    :  return( Utils.file_fullname( file.get_path() ) );
      case FILE_BASE    :  return( Utils.file_name( file.get_path() ) );
      case FILE_EXT     :  return( Utils.file_extension( file.get_path() ) );
      case FILE_CDATE   :  return( Utils.date_to_string( Utils.file_create_date( file.get_path() ), date_pattern ) );
      case FILE_MDATE   :  return( Utils.date_to_string( Utils.file_modify_date( file.get_path() ), date_pattern ) );
      case TODAY        :  return( Utils.date_to_string( new DateTime.now(), date_pattern ) );
      case FILE_OWNER   :  return( Utils.file_owner( file.get_path() ) );
      case FILE_GROUP   :  return( Utils.file_group( file.get_path() ) );
      case UNIQUE_ID    :  return( "XXXXXX" );
      case IMAGE_WIDTH  :  return( Utils.image_width( file.get_path() ).to_string() );
      case IMAGE_HEIGHT :  return( Utils.image_height( file.get_path() ).to_string() );
      default           :  assert_not_reached();
    }
  }

  public bool is_text() {
    return( this == TEXT );
  }

  public bool is_file_part() {
    switch( this ) {
      case FILE_FULL    :
      case FILE_BASE    :
      case FILE_EXT     :
      case FILE_OWNER   :
      case FILE_GROUP   :
      case UNIQUE_ID    :
      case IMAGE_WIDTH  :
      case IMAGE_HEIGHT :  return( true );
      default           :  return( false );
    }
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

public enum TextTokenFormat {
  NO_ZERO,
  ONE_ZERO,
  TWO_ZERO,
  THREE_ZERO,
  FOUR_ZERO,
  FIVE_ZERO,
  NUM;

  public string to_string() {
    switch( this ) {
      case NO_ZERO    :  return( "0" );
      case ONE_ZERO   :  return( "1" );
      case TWO_ZERO   :  return( "2" );
      case THREE_ZERO :  return( "3" );
      case FOUR_ZERO  :  return( "4" );
      case FIVE_ZERO  :  return( "5" );
      default         :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case NO_ZERO    :  return( "1" );
      case ONE_ZERO   :  return( "01" );
      case TWO_ZERO   :  return( "001" );
      case THREE_ZERO :  return( "0001" );
      case FOUR_ZERO  :  return( "00001" );
      case FIVE_ZERO  :  return( "000001" );
      default         :  assert_not_reached();
    }
  }

  public string format() {
    switch( this ) {
      case NO_ZERO    :  return( "%d" );
      case ONE_ZERO   :  return( "%02d" );
      case TWO_ZERO   :  return( "%03d" );
      case THREE_ZERO :  return( "%04d" );
      case FOUR_ZERO  :  return( "%05d" );
      case FIVE_ZERO  :  return( "%06d" );
      default         :  assert_not_reached();
    }
  }

  public static TextTokenFormat parse( string val ) {
    switch( val ) {
      case "0" :  return( NO_ZERO );
      case "1" :  return( ONE_ZERO );
      case "2" :  return( TWO_ZERO );
      case "3" :  return( THREE_ZERO );
      case "4" :  return( FOUR_ZERO );
      case "5" :  return( FIVE_ZERO );
      default  :  assert_not_reached();
    }
  }

}

public class TextToken {

  public static const string xml_node = "text-token";

  public TextTokenType     token_type { get; private set; default = TextTokenType.TEXT; }
  public string            text       { get; set; default = ""; }
  public TextTokenModifier modifier   { get; set; default = TextTokenModifier.NONE; }
  public TextTokenFormat   id_format  { get; set; default = TextTokenFormat.NO_ZERO; }

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
    modifier   = other.modifier;
    id_format  = other.id_format;
  }

  /* Generates the text associated with this token */
  public string generate_text( File file ) {
    if( token_type == TextTokenType.UNIQUE_ID ) {
      return( id_format.format() );
    } else {
      return( modifier.format( token_type.convert( file, text ) ) );
    }
  }

  /* Saves this instance in XML format */
  public Xml.Node* save() {
    Xml.Node* node = new Xml.Node( null, xml_node );
    node->set_prop( "type", token_type.to_string() );
    node->set_prop( "text", text );
    node->set_prop( "modifier", modifier.to_string() );
    node->set_prop( "id-format", id_format.to_string() );
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
    var fmt = node->get_prop( "id-format" );
    if( fmt != null ) {
      id_format = TextTokenFormat.parse( fmt );
    }
  }

}

public class TokenText {

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

  /* Returns the number of tokens stored */
  public int num_tokens() {
    return( (int)_tokens.length() );
  }

  /* Returns the token at the given index */
  public TextToken get_token( int index ) {
    return( _tokens.nth_data( index ) );
  }

  /* Adds the given token to the list */
  public void add_token( TextToken token ) {
    _tokens.append( token );
  }

  /*
   Substitutes any unique ID strings in the embedded string such that it will be a unique filename within the file's
   directory.
  */
  private string insert_unique_ids( File file, string str ) {
    var parts = str.split( "%" );
    if( parts.length == 1 ) {
      return( str );
    }
    var dir   = file.get_parent().get_path();
    var num   = 1;
    var fname = "";
    do {
      fname = str.printf( num++ );
    } while( FileUtils.test( Path.build_filename( dir, fname ), FileTest.EXISTS ) );
    return( fname );
  }

  /* Generates the text string based on the tokens */
  public string generate_text( File file ) {
    var str = "";
    _tokens.foreach((token) => {
      str += token.generate_text( file );
    });
    return( insert_unique_ids( file, str ) );
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
