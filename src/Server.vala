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
    return(
      Secret.password_store_sync(
        _schema, Secret.COLLECTION_DEFAULT, "password", password, null,
        "conn-type", (int)_conn_type, "host", _host, "port", _port, false
      )
    );
  }

  /* Returns the password from the keyring */
  public string get_password() {
    return(
      Secret.password_lookup_sync(
        _schema, null, "conn-type", (int)_conn_type, "host", _host, "port", _port, false
      )
    );
  }

  /* Opens a connection to the server */
  public async bool connect( MainWindow win, string path ) {

    var uri   = _conn_type.to_string() + "://" + _user + ":" + get_password() + "@" + _host + ":" + _port.to_string() + path;
    var mount = new Gtk.MountOperation( win );
    mount.set_domain( _host );

    /* Get the handle to the mounted host */
    _handle = File.new_for_uri( uri );

    try {
      return yield _handle.mount_enclosing_volume( MountMountFlags.NONE, mount, null );
    } catch( Error e ) {
      return( false );
    }

  }

  /* Disconnects the current connection */
  public async bool disconnect() {

    try {
      return yield _handle.eject_mountable_with_operation( MountUnmountFlags.NONE, null );
    } catch( Error e ) {
      return( false );
    }

  }

  /* Uploads the given file to this server */
  public bool upload( MainWindow win, File src, string path ) {

    var retval = false;

    /* Connect to the server */
    connect.begin( win, path, (obj, res) => {

      if( connect.end( res ) ) {

        var dst = _handle.get_child( src.get_basename() );

        // TBD - Perform copy operation
        src.copy_async.begin( dst, FileCopyFlags.OVERWRITE, Priority.DEFAULT, null, null, (obj, res) => {
          if( src.copy_async.end( res ) ) {
            retval = true;
          }
        });

        disconnect.begin((obj, res) => {
          retval &= disconnect.end( res );
        });

      }

    });

    return( false );

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
