public enum ServerConnectType {
  FTP,
  SFTP,
  DAV,
  NUM;

  public string to_string() {
    switch( this ) {
      case FTP  :  return( "ftp" );
      case SFTP :  return( "sftp" );
      case DAV  :  return( "dav" );
      default   :  assert_not_reached();
    }
  }

  public static ServerConnectType parse( string val ) {
    switch( val ) {
      case "ftp"  :  return( FTP );
      case "sftp" :  return( SFTP );
      case "dav"  :  return( DAV );
      default     :  assert_not_reached();
    }
  }

  public int port() {
    switch( this ) {
      case FTP  :  return( 21 );
      case SFTP :  return( 22 );
      case DAV  :  return( 443 );
      default   :  assert_not_reached();
    }
  }

}

public class Server {

  private const string SECRET_SCHEMA = "com.github.phase1geo.Actioneer";
  private static Secret.Schema? _schema = null;

  private string            _name;
  private ServerConnectType _conn_type;
  private string            _host;
  private int               _port;
  private string            _user;
  private File?             _handle;

  public const string xml_node = "server";

  public string name {
    get {
      return( _name );
    }
  }
  public ServerConnectType conn_type {
    get {
      return( _conn_type );
    }
  }
  public string host {
    get {
      return( _host );
    }
  }
  public int port {
    get {
      return( _port );
    }
  }
  public string user {
    get {
      return( _user );
    }
  }

  /* Default constructor */
  public Server() {
    create_schema();
    _name      = "";
    _conn_type = ServerConnectType.FTP;
    _host      = "";
    _port      = 22;
    _user      = "";
    _handle    = null;
  }

  /* Copy constructor */
  public Server.copy( Server other ) {
    _name      = other._name;
    _conn_type = other._conn_type;
    _host      = other._host;
    _port      = other._port;
    _user      = other._user;
  }

  /* Creates the password schema */
  private void create_schema() {
    if( _schema == null ) {
      _schema = new Secret.Schema(
        SECRET_SCHEMA, Secret.SchemaFlags.NONE,
        "conn-type", Secret.SchemaAttributeType.INTEGER,
        "host",      Secret.SchemaAttributeType.STRING,
        "port",      Secret.SchemaAttributeType.INTEGER,
        "user",      Secret.SchemaAttributeType.STRING
      );
    }
  }

  /* Stores the connection information and saves the password to the keyring */
  public bool store( string name, ServerConnectType conn_type, string host, int port, string user, string password ) {
    _name      = name;
    _conn_type = conn_type;
    _host      = host;
    _port      = port;
    _user      = user;
    try {
      return(
        Secret.password_store_sync(
          _schema, Secret.COLLECTION_DEFAULT, "password", password, null,
          "conn-type", (int)_conn_type, "host", _host, "port", _port, false
        )
      );
    } catch( Error e ) {
      return( false );
    }
  }

  public bool unstore() {
    try {
      return(
        Secret.password_clear_sync(
          _schema, null,
          "conn-type", (int)_conn_type, "host", _host, "port", _port, false
        )
      );
    } catch( Error e ) {
      return( false );
    }
  }

  /* Returns the password from the keyring */
  public string? get_password() {
    try {
      return(
        Secret.password_lookup_sync(
          _schema, null, "conn-type", (int)_conn_type, "host", _host, "port", _port, false
        )
      );
    } catch( Error e ) {
      return( null );
    }
  }

  /* Opens a connection to the server */
  public async bool connect( MainWindow win, string path ) {

    var uri = Uri.build_with_user( UriFlags.HAS_PASSWORD, _conn_type.to_string(), _user, get_password(), null, _host, _port, path, null, null );

    var mop = new GLib.MountOperation();
    mop.set_domain( _host );
    mop.set_username( _user );
    mop.set_password( get_password() );
    mop.set_password_save( PasswordSave.NEVER );
    mop.ask_password.connect((m,u,d,f) => {
      mop.reply( MountOperationResult.HANDLED );
    });

    /* Get the handle to the mounted host */
    _handle = File.new_for_uri( uri.to_string_partial( UriHideFlags.PASSWORD ) );

    try {
      return yield _handle.mount_enclosing_volume( MountMountFlags.NONE, mop, null );
    } catch( Error e ) {
      stdout.printf( "A ERROR: %s\n", e.message );
      return( false );
    }

  }

  /* Disconnects the current connection */
  public async bool disconnect( MainWindow win ) {

    var mount = _handle.find_enclosing_mount();

    try {
      return yield mount.unmount_with_operation( MountUnmountFlags.NONE, null, null );
    } catch( Error e ) {
      stdout.printf( "B ERROR: %s\n", e.message );
      return( false );
    }

  }

  /* Tests to make sure that the connection works */
  public async bool test( MainWindow win ) {

    if( yield connect( win, "" ) ) {
      if( yield disconnect( win ) ) {
        return( true );
      }
    }

    return( false );

  }

  /* Uploads the given file to this server */
  public async bool upload( MainWindow win, File src, string path ) {

    var retval = false;

    /* Connect to the server */
    if( yield connect( win, path ) ) {

      var dst = _handle.get_child( src.get_basename() );

      /* Perform copy operation */
      if( yield src.copy_async( dst, FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, null ) ) {
        retval = true;
      }

      /* Disconnect after the copy has completed */
      retval &= yield disconnect( win );

    }

    return( retval );

  }

  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "name",      _name );
    node->set_prop( "conn-type", _conn_type.to_string() );
    node->set_prop( "host",      _host );
    node->set_prop( "port",      _port.to_string() );
    node->set_prop( "user",      _user );

    return( node );

  }

  public void load( Xml.Node* node ) {

    var n = node->get_prop( "name" );
    if( n != null ) {
      _name = n;
    }

    var ct = node->get_prop( "conn-type" );
    if( ct != null ) {
      _conn_type = ServerConnectType.parse( ct );
    }

    var h = node->get_prop( "host" );
    if( h != null ) {
      _host = h;
    }

    var p = node->get_prop( "port" );
    if( p != null ) {
      _port = int.parse( p );
    }

    var u = node->get_prop( "user" );
    if( u != null ) {
      _user = u;
    }

  }

}
