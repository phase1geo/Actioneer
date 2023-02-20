public enum FileActionType {
  MOVE,
  COPY,
  RENAME,
  ALIAS,
  UPLOAD,
  COMPRESS,
  DECOMPRESS,
  TRASH,
  ADD_TAG,
  REMOVE_TAG,
  CLEAR_TAGS,
  STARS,
  COMMENT,
  IMG_RESIZE,
  IMG_CONVERT,
  NOTIFY,
  RUN_SCRIPT,
  OPEN,
  NUM;

  public string to_string() {
    switch( this ) {
      case MOVE        :  return( "move" );
      case COPY        :  return( "copy" );
      case RENAME      :  return( "rename" );
      case ALIAS       :  return( "alias" );
      case UPLOAD      :  return( "upload" );
      case COMPRESS    :  return( "compress" );
      case DECOMPRESS  :  return( "decompress" );
      case TRASH       :  return( "trash" );
      case ADD_TAG     :  return( "tag-add" );
      case REMOVE_TAG  :  return( "tag-remove" );
      case CLEAR_TAGS  :  return( "tag-clear" );
      case STARS       :  return( "stars" );
      case COMMENT     :  return( "comment" );
      case IMG_RESIZE  :  return( "img-resize" );
      case IMG_CONVERT :  return( "img-convert" );
      case NOTIFY      :  return( "notify" );
      case RUN_SCRIPT  :  return( "run-script" );
      case OPEN        :  return( "open" );
      default          :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case MOVE        :  return( _( "Move" ) );
      case COPY        :  return( _( "Copy" ) );
      case RENAME      :  return( _( "Rename" ) );
      case ALIAS       :  return( _( "Alias" ) );
      case UPLOAD      :  return( _( "Upload" ) );
      case COMPRESS    :  return( _( "Compress" ) );
      case DECOMPRESS  :  return( _( "Decompress" ) );
      case TRASH       :  return( _( "Trash" ) );
      case ADD_TAG     :  return( _( "Add Tag" ) );
      case REMOVE_TAG  :  return( _( "Remove Tag" ) );
      case CLEAR_TAGS  :  return( _( "Clear Tags" ) );
      case STARS       :  return( _( "Rating" ) );
      case COMMENT     :  return( _( "Comment" ) );
      case IMG_RESIZE  :  return( _( "Resize Image" ) );
      case IMG_CONVERT :  return( _( "Convert Image" ) );
      case NOTIFY      :  return( _( "Notify" ) );
      case RUN_SCRIPT  :  return( _( "Run Script" ) );
      case OPEN        :  return( _( "Open" ) );
      default          :  assert_not_reached();
    }
  }

  public string pretext() {
    switch( this ) {
      case MOVE        :  return( _( "to folder" ) );
      case COPY        :  return( _( "to folder" ) );
      case RENAME      :  return( _( "file as" ) );
      case ALIAS       :  return( _( "from folder" ) );
      case UPLOAD      :  return( _( "to" ) );
      case COMPRESS    :  return( _( "file to format" ) );
      case DECOMPRESS  :  return( _( "compressed file" ) );
      case TRASH       :  return( _( "file" ) );
      case ADD_TAG     :  return( _( "to file" ) );
      case REMOVE_TAG  :  return( _( "from file" ) );
      case CLEAR_TAGS  :  return( _( "from file" ) );
      case STARS       :  return( _( "for file" ) );
      case COMMENT     :  return( _( "for file" ) );
      case IMG_RESIZE  :  return( "" );
      case IMG_CONVERT :  return( _( "with format" ) );
      case NOTIFY      :  return( _( "with message" ) );
      case RUN_SCRIPT  :  return( "" );
      case OPEN        :  return( _( "with application" ) );
      default          :  assert_not_reached();
    }
  }

  public static FileActionType parse( string val, bool assert_if_not_found = true ) {
    switch( val ) {
      case "move"        :  return( MOVE );
      case "copy"        :  return( COPY );
      case "rename"      :  return( RENAME );
      case "alias"       :  return( ALIAS );
      case "upload"      :  return( UPLOAD );
      case "compress"    :  return( COMPRESS );
      case "decompress"  :  return( DECOMPRESS );
      case "trash"       :  return( TRASH );
      case "tag-add"     :  return( ADD_TAG );
      case "tag-remove"  :  return( REMOVE_TAG );
      case "tag-clear"   :  return( CLEAR_TAGS );
      case "stars"       :  return( STARS );
      case "comment"     :  return( COMMENT );
      case "img-resize"  :  return( IMG_RESIZE );
      case "img-convert" :  return( IMG_CONVERT );
      case "notify"      :  return( NOTIFY );
      case "run-script"  :  return( RUN_SCRIPT );
      case "open"        :  return( OPEN );
      default            :
        if( assert_if_not_found ) {
          assert_not_reached();
        } else {
          return( NUM );
        }
        break;
    }
  }

  public static FileActionType match_to_label( string val ) {
    for( int i=0; i<NUM; i++ ) {
      var type = (FileActionType)i;
      if( type.label().down() == val.down() ) {
        return( type );
      }
    }
    return( NUM );
  }

  public bool add_separator_after() {
    return( (this == ALIAS) ||
            (this == UPLOAD) ||
            (this == DECOMPRESS) ||
            (this == TRASH) ||
            (this == COMMENT) ||
            (this == IMG_CONVERT) );
  }

  private string? do_move( string pathname, File new_file ) {
    var ofile  = File.new_for_path( pathname );
    var nfile  = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    return( ofile.move( nfile, FileCopyFlags.NONE ) ? pathname : null );
  }

  private string? do_copy( string pathname, File new_file ) {
    var ofile = File.new_for_path( pathname );
    var nfile = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    return( (!FileUtils.test( nfile.get_path(), FileTest.EXISTS ) &&
             ofile.copy( nfile, FileCopyFlags.NONE )) ? pathname : null );
  }

  private string? do_rename( string pathname, TokenText token_text ) {
    var ofile  = File.new_for_path( pathname );
    var nfile  = File.new_for_path( Path.build_filename( ofile.get_parent().get_path(), token_text.generate_text( ofile ) ) );
    return( ofile.move( nfile, FileCopyFlags.NONE ) ? nfile.get_path() : null );
  }

  private string? do_alias( string pathname, File new_file ) {
    var ofile = File.new_for_path( pathname );
    var nfile = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    return( (!FileUtils.test( nfile.get_path(), FileTest.EXISTS ) &&
             nfile.make_symbolic_link( ofile.get_path() )) ? pathname : null );
  }

  private string? do_compress( string pathname, FileCompress comp ) {
    var ifile = File.new_for_path( pathname );
    var nfile = File.new_for_path( pathname + comp.extension() );
    return( comp.compress( ifile, nfile ) ? nfile.get_path() : null );
  }

  private string? do_decompress( string pathname ) {
    var ifile    = File.new_for_path( pathname );
    var comp     = new FileCompress();
    var new_path = "";
    if( comp.set_type_from_path( pathname, out new_path ) ) {
      var nfile = File.new_for_path( new_path );
      return( comp.decompress( ifile, nfile ) ? new_path : null );
    }
    return( null );
  }

  private string? do_trash( string pathname ) {
    var ofile = File.new_for_path( pathname );
    return( ofile.trash() ? pathname : null );
  }

  private string? do_add_tag( string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var tag   = token_text.generate_text( ofile );
    return( Utils.file_add_tag( pathname, tag ) ? pathname : null );
  }

  private string? do_remove_tag( string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var tag   = token_text.generate_text( ofile );
    return( Utils.file_remove_tag( pathname, tag ) ? pathname : null );
  }

  private string? do_clear_tags( string pathname ) {
    return( Utils.file_clear_tags( pathname ) ? pathname : null );
  }

  private string? do_rating( string pathname, TokenText token_text ) {
    if( token_text.num_tokens() > 0 ) {
      var token = token_text.get_token( 0 );
      if( token.token_type == TextTokenType.TEXT ) {
        var val = int.parse( token.text );
        return( Utils.set_file_stars( pathname, val ) ? pathname : null );
      }
    }
    return( null );
  }

  private string? do_comment( string pathname, TokenText token_text ) {
    var ofile   = File.new_for_path( pathname );
    var comment = token_text.generate_text( ofile );
    return( Utils.set_file_comment( pathname, comment ) ? pathname : null );
  }

  private string? do_image_resize( string pathname, Imager imager ) {
    return( imager.resize( pathname ) ? pathname : null );
  }

  private string? do_image_convert( string pathname, Imager imager ) {
    var path = pathname;
    return( imager.convert( ref path ) ? path : null );
  }

  private string? do_notify( GLib.Application app, string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var msg   = token_text.generate_text( ofile );
    var notification = new Notification( _( "Actioneer" ) );
    notification.set_body( msg );
    app.send_notification( "com.github.phase1geo.actioneer", notification );
    Utils.show_file_info( pathname );
    return( pathname );
  }

  /* Executes a script determined by token_text */
  private string? do_run_script( string pathname, TokenText token_text ) {
    var ofile  = File.new_for_path( pathname );
    var script = token_text.generate_text( ofile );
    return( Process.spawn_command_line_async( script ) ? pathname : null );
  }

  /* Opens the given pathname in the default application */
  private string? do_open( string pathname, AppInfo? opener ) {
    var ofile = File.new_for_path( pathname );
    if( opener == null ) {
      return( AppInfo.launch_default_for_uri( ofile.get_uri(), null ) ? pathname : null );
    } else {
      var uris = new List<string>();
      uris.append( ofile.get_uri() );
      return( opener.launch_uris( uris, null ) ? pathname : null );
    }
  }

  private async string? do_upload( string pathname, ServerConnection conn ) {
    var ofile  = File.new_for_path( pathname );
    var retval = yield conn.server.upload( ofile, conn.path );
    return( retval ? pathname : null );
  }

  public async string? file_execute(
    GLib.Application app, string pathname,
    File? new_file, TokenText? token_text, FileCompress? comp, Imager? imager, AppInfo? opener, ServerConnection? conn
  ) {
    switch( this ) {
      case MOVE        :  return( do_move( pathname, new_file ) );
      case COPY        :  return( do_copy( pathname, new_file ) );
      case RENAME      :  return( do_rename( pathname, token_text ) );
      case ALIAS       :  return( do_alias( pathname, new_file ) );
      case UPLOAD      :  return( yield do_upload( pathname, conn ) );
      case COMPRESS    :  return( do_compress( pathname, comp ) );
      case DECOMPRESS  :  return( do_decompress( pathname ) );
      case TRASH       :  return( do_trash( pathname ) );
      case ADD_TAG     :  return( do_add_tag( pathname, token_text ) );
      case REMOVE_TAG  :  return( do_remove_tag( pathname, token_text ) );
      case CLEAR_TAGS  :  return( do_clear_tags( pathname ) );
      case STARS       :  return( do_rating( pathname, token_text ) );
      case COMMENT     :  return( do_comment( pathname, token_text ) );
      case IMG_RESIZE  :  return( do_image_resize( pathname, imager ) );
      case IMG_CONVERT :  return( do_image_convert( pathname, imager ) );
      case NOTIFY      :  return( do_notify( app, pathname, token_text ) );
      case RUN_SCRIPT  :  return( do_run_script( pathname, token_text ) );
      case OPEN        :  return( do_open( pathname, opener ) );
      default          :  assert_not_reached();
    }
  }

  public bool is_file_type() {
    switch( this ) {
      case MOVE     :
      case COPY     :
      case ALIAS    :  return( true );
      default       :  return( false );
    }
  }

  public bool is_tokenized() {
    switch( this ) {
      case RENAME     :
      case NOTIFY     :
      case ADD_TAG    :
      case REMOVE_TAG :
      case STARS      :
      case COMMENT    :
      case RUN_SCRIPT :  return( true );
      default         :  return( false );
    }
  }

  public bool is_compress() {
    return( this == COMPRESS );
  }

  public bool is_image_resize() {
    return( this == IMG_RESIZE );
  }

  public bool is_image_convert() {
    return( this == IMG_CONVERT );
  }

  public bool is_open() {
    return( this == OPEN );
  }

  public bool is_upload() {
    return( this == UPLOAD );
  }

}

public class FileAction {

  public static const string xml_node = "file-action";

  private FileActionType    _type;
  private File?             _file;
  private TokenText?        _token_text;
  private FileCompress?     _compress;
  private Imager?           _imager;
  private AppInfo?          _opener;
  private ServerConnection? _conn;

  public FileActionType action_type {
    get {
      return( _type );
    }
  }
  public File? file {
    get {
      return( _file );
    }
  }
  public TokenText? token_text {
    get {
      return( _token_text );
    }
  }
  public FileCompress? compress {
    get {
      return( _compress );
    }
  }
  public Imager? imager {
    get {
      return( _imager );
    }
  }
  public AppInfo? opener {
    get {
      return( _opener );
    }
    set {
      _opener = value;
    }
  }
  public ServerConnection? conn {
    get {
      return( _conn );
    }
    set {
      _conn = value;
    }
  }

  public bool   err    { get; set; default = false; }
  public string errmsg { get; set; default = ""; }

  /* Default Constructor */
  public FileAction() {
    _type       = FileActionType.MOVE;
    _file       = null;
    _token_text = null;
    _compress   = null;
    _imager     = null;
    _opener     = null;
    _conn       = null;
  }

  /* Constructor */
  public FileAction.with_type( FileActionType type ) {
    _type       = type;
    _file       = null;
    _token_text = type.is_tokenized() ? new TokenText()    : null;
    _compress   = type.is_compress()  ? new FileCompress() : null;
    if( type.is_image_resize() ) {
      _imager = new ImagerResizer();
    } else if( type.is_image_convert() ) {
      _imager = new ImagerConverter();
    } else {
      _imager = null;
    }
    _opener = null;
    _conn   = type.is_upload() ? new ServerConnection() : null;
  }

  /* Constructor */
  public FileAction.with_filename( FileActionType type, string filename ) {
    assert( type.is_file_type() );
    _type       = type;
    _file       = File.new_for_path( filename );
    _token_text = type.is_tokenized() ? new TokenText()    : null;
    _compress   = type.is_compress()  ? new FileCompress() : null;
    if( type.is_image_resize() ) {
      _imager = new ImagerResizer();
    } else if( type.is_image_convert() ) {
      _imager = new ImagerConverter();
    } else {
      _imager = null;
    }
    _opener = null;
    _conn   = type.is_upload() ? new ServerConnection() : null;
  }

  /* Copy constructor */
  public FileAction.copy( FileAction other ) {
    _type       = other._type;
    _file       = (other._file       == null) ? null : File.new_for_path( other._file.get_path() );
    _token_text = (other._token_text == null) ? null : new TokenText.copy( other._token_text );
    _compress   = (other._compress   == null) ? null : new FileCompress.copy( other._compress );
    if( other._imager == null ) {
      _imager = null;
    } else if( (other._imager as ImagerResizer) != null ) {
      _imager = new ImagerResizer.copy( (other._imager as ImagerResizer) );
    } else if( (other._imager as ImagerConverter) != null ) {
      _imager = new ImagerConverter.copy( (other._imager as ImagerConverter) );
    }
    _opener = other._opener;
    _conn   = (other._conn == null) ? null : new ServerConnection.copy( other._conn );
  }

  /*
   Executes the action and returns true if it was successful.  If true is returned,
   the err and errmsg value will be updated with the error information.  If the
   pathname is changed by the action, updates the pathname value.
  */
  public async string? execute( GLib.Application app, string pathname ) {

    try {
      return( yield _type.file_execute( app, pathname, _file, _token_text, _compress, _imager, _opener, _conn ) );
    } catch( SpawnError e ) {
      err    = true;
      errmsg = e.message;
    } catch( Error e ) {
      err    = true;
      errmsg = e.message;
    }

    return( null );

  }

  /* Returns true if this action references the given server */
  public bool server_in_use( string name ) {
    return( (_conn != null) && (_conn.server.name == name) );
  }

  /* Returns true if our entry matches the given value */
  public bool matches( string value ) {
    if( _type.is_file_type() ) {
      return( _file.get_path().contains( value ) );
    } else if( _type.is_tokenized() ) {
      return( _token_text.matches( value ) );
    } else if( _type.is_compress() ) {
      return( _compress.matches( value ) );
    } else if( _type.is_image_resize() || _type.is_image_convert() ) {
      return( _imager.matches( value ) );
    } else if( _type.is_open() ) {
      return( (_opener == null) ? _( "Default" ).contains( value ) : _opener.get_name().contains( value ) );
    } else if( _type.is_upload() ) {
      return( _conn.matches( value ) );
    }
    return( false );
  }

  /* Save this instance in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type", _type.to_string() );

    if( _file != null ) {
      node->set_prop( "file", _file.get_path() );
    }

    if( _token_text != null ) {
      node->add_child( _token_text.save() );
    }

    if( _compress != null ) {
      node->add_child( _compress.save() );
    }

    if( _imager != null ) {
      _imager.save( node );
    }

    if( _type.is_open() ) {
      node->set_prop( "app-id", (_opener == null) ? "" : _opener.get_id() );
    }

    if( _conn != null ) {
      node->add_child( _conn.save() );
    }

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

    var ia = node->get_prop( "app-id" );
    if( ia != null ) {
      _opener = AppList.get_app_with_id( ia );
    }

    if( _type.is_image_resize() ) {
      _imager = new ImagerResizer();
      _imager.load( node );
    } else if( _type.is_image_convert() ) {
      _imager = new ImagerConverter();
      _imager.load( node );
    }

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( it->type == Xml.ElementType.ELEMENT_NODE ) {
        switch( it->name ) {
          case TokenText.xml_node :
            _token_text = new TokenText();
            _token_text.load( it );
            break;
          case FileCompress.xml_node :
            _compress = new FileCompress();
            _compress.load( it );
            break;
          case ServerConnection.xml_node :
            _conn = new ServerConnection();
            _conn.load( it );
            break;
        }
      }
    }

  }

}
