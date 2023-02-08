public enum FileActionType {
  MOVE,
  COPY,
  RENAME,
  ALIAS,
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

  public static FileActionType parse( string val ) {
    switch( val ) {
      case "move"        :  return( MOVE );
      case "copy"        :  return( COPY );
      case "rename"      :  return( RENAME );
      case "alias"       :  return( ALIAS );
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
      default            :  assert_not_reached();
    }
  }

  public bool add_separator_after() {
    return( (this == ALIAS) ||
            (this == DECOMPRESS) ||
            (this == TRASH) ||
            (this == COMMENT) ||
            (this == IMG_CONVERT) );
  }

  private bool do_move( ref string pathname, File new_file ) {
    var ofile  = File.new_for_path( pathname );
    var nfile  = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    var retval = ofile.move( nfile, FileCopyFlags.NONE );
    pathname   = nfile.get_path();
    return( retval );
  }

  private bool do_copy( string pathname, File new_file ) {
    var ofile = File.new_for_path( pathname );
    var nfile = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    return( !FileUtils.test( nfile.get_path(), FileTest.EXISTS ) &&
            ofile.copy( nfile, FileCopyFlags.NONE ) );
  }

  private bool do_rename( ref string pathname, TokenText token_text ) {
    var ofile  = File.new_for_path( pathname );
    var nfile  = File.new_for_path( Path.build_filename( ofile.get_parent().get_path(), token_text.generate_text( ofile ) ) );
    var retval = ofile.move( nfile, FileCopyFlags.NONE );
    pathname   = nfile.get_path();
    return( retval );
  }

  private bool do_alias( string pathname, File new_file ) {
    var ofile = File.new_for_path( pathname );
    var nfile = File.new_for_path( Path.build_filename( new_file.get_path(), ofile.get_basename() ) );
    return( !FileUtils.test( nfile.get_path(), FileTest.EXISTS ) &&
            nfile.make_symbolic_link( ofile.get_path() ) );
  }

  private bool do_compress( ref string pathname, FileCompress comp ) {
    var ifile = File.new_for_path( pathname );
    var nfile = File.new_for_path( pathname + comp.extension() );
    pathname = nfile.get_path();
    return( comp.compress( ifile, nfile ) );
  }

  private bool do_decompress( string pathname ) {
    string new_path;
    var ifile = File.new_for_path( pathname );
    var comp  = new FileCompress();
    if( comp.set_type_from_path( pathname, out new_path ) ) {
      var nfile = File.new_for_path( new_path );
      return( comp.decompress( ifile, nfile ) );
    }
    return( false );
  }

  private bool do_trash( string pathname ) {
    var ofile = File.new_for_path( pathname );
    return( ofile.trash() );
  }

  private bool do_add_tag( string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var tag   = token_text.generate_text( ofile );
    return( Utils.file_add_tag( pathname, tag ) );
  }

  private bool do_remove_tag( string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var tag   = token_text.generate_text( ofile );
    return( Utils.file_remove_tag( pathname, tag ) );
  }

  private bool do_clear_tags( string pathname ) {
    return( Utils.file_clear_tags( pathname ) );
  }

  private bool do_rating( string pathname, TokenText token_text ) {
    if( token_text.num_tokens() > 0 ) {
      var token = token_text.get_token( 0 );
      if( token.token_type == TextTokenType.TEXT ) {
        var val = int.parse( token.text );
        return( Utils.set_file_stars( pathname, val ) );
      }
    }
    return( false );
  }

  private bool do_comment( string pathname, TokenText token_text ) {
    var ofile   = File.new_for_path( pathname );
    var comment = token_text.generate_text( ofile );
    return( Utils.set_file_comment( pathname, comment ) );
  }

  private bool do_image_resize( string pathname, Imager imager ) {
    return( imager.resize( pathname ) );
  }

  private bool do_image_convert( ref string pathname, Imager imager ) {
    return( imager.convert( ref pathname ) );
  }

  private bool do_notify( GLib.Application app, string pathname, TokenText token_text ) {
    var ofile = File.new_for_path( pathname );
    var msg   = token_text.generate_text( ofile );
    var notification = new Notification( _( "Actioneer" ) );
    notification.set_body( msg );
    app.send_notification( "com.github.phase1geo.actioneer", notification );
    Utils.show_file_info( pathname );
    return( true );
  }

  /* Executes a script determined by token_text */
  private bool do_run_script( string pathname, TokenText token_text ) {
    var ofile  = File.new_for_path( pathname );
    var script = token_text.generate_text( ofile );
    return( Process.spawn_command_line_async( script ) );
  }

  /* Opens the given pathname in the default application */
  private bool do_open( string pathname, AppInfo? opener ) {
    var ofile = File.new_for_path( pathname );
    if( opener == null ) {
      return( AppInfo.launch_default_for_uri( ofile.get_uri(), null ) );
    } else {
      var uris = new List<string>();
      uris.append( ofile.get_uri() );
      return( opener.launch_uris( uris, null ) );
    }
  }

  public bool file_execute(
    GLib.Application app, ref string pathname,
    File? new_file, TokenText? token_text, FileCompress? comp, Imager? imager, AppInfo? opener ) {
    switch( this ) {
      case MOVE        :  return( do_move( ref pathname, new_file ) );
      case COPY        :  return( do_copy( pathname, new_file ) );
      case RENAME      :  return( do_rename( ref pathname, token_text ) );
      case ALIAS       :  return( do_alias( pathname, new_file ) );
      case COMPRESS    :  return( do_compress( ref pathname, comp ) );
      case DECOMPRESS  :  return( do_decompress( pathname ) );
      case TRASH       :  return( do_trash( pathname ) );
      case ADD_TAG     :  return( do_add_tag( pathname, token_text ) );
      case REMOVE_TAG  :  return( do_remove_tag( pathname, token_text ) );
      case CLEAR_TAGS  :  return( do_clear_tags( pathname ) );
      case STARS       :  return( do_rating( pathname, token_text ) );
      case COMMENT     :  return( do_comment( pathname, token_text ) );
      case IMG_RESIZE  :  return( do_image_resize( pathname, imager ) );
      case IMG_CONVERT :  return( do_image_convert( ref pathname, imager ) );
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

}

public class FileAction {

  public static const string xml_node = "file-action";

  private FileActionType _type;
  private File?          _file;
  private TokenText?     _token_text;
  private FileCompress?  _compress;
  private Imager?        _imager;
  private AppInfo?       _opener;

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
  }

  /*
   Executes the action and returns true if it was successful.  If true is returned,
   the err and errmsg value will be updated with the error information.  If the
   pathname is changed by the action, updates the pathname value.
  */
  public bool execute( GLib.Application app, ref string pathname ) {

    try {
      return( _type.file_execute( app, ref pathname, _file, _token_text, _compress, _imager, _opener ) );
    } catch( SpawnError e ) {
      err    = true;
      errmsg = e.message;
    } catch( Error e ) {
      err    = true;
      errmsg = e.message;
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
        }
      }
    }

  }

}
