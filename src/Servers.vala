public class Servers {

  public static const string xml_node = "servers";

  Array<Server> _servers;

  /* Default constructor */
  public Servers() {
    _servers = new Array<Server>();
  }

  public int num() {
    return( (int)_servers.length );
  }

  public void add_server( Server server ) {
    _servers.append_val( server );
  }

  public Server get_server( int index ) {
    return( _servers.index( index ) );
  }

  public Server? get_server_by_name( string name ) {
    for( int i=0; i<_servers.length; i++ ) {
      if( _servers.index( i ).name == name ) {
        return( _servers.index( i ) );
      }
    }
    return( null );
  }

  public int get_server_index( string name ) {
    for( int i=0; i<_servers.length; i++ ) {
      if( _servers.index( i ).name == name ) {
        return( i );
      }
    }
    return( -1 );
  }

  public void remove_server( int index ) {
    _servers.remove_index( index );
  }

  public bool remove_server_by_name( string name ) {
    for( int i=0; i<_servers.length; i++ ) {
      if( _servers.index( i ).name == name ) {
        _servers.remove_index( i );
        return( true );
      }
    }
    return( false );
  }

  /* Returns the rules.xml complete filepath */
  private string? servers_filename( bool create_if_nonexistent ) {

    var dir = GLib.Path.build_filename( Environment.get_user_data_dir(), "actioneer" );
    if( create_if_nonexistent && (DirUtils.create_with_parents( dir, 0775 ) != 0) ) {
      return( null );
    }

    return( GLib.Path.build_filename( dir, "servers.xml" ) );

  }

  /* Saves the rules.xml file to the filesystem */
  public bool save() {

    var fname = servers_filename( true );
    if( fname == null ) {
      return( false );
    }

    Xml.Doc*  doc  = new Xml.Doc( "1.0" );
    Xml.Node* root = new Xml.Node( null, "actioneer-servers" );

    root->set_prop( "version", Actioneer.version );

    for( int i=0; i<_servers.length; i++ ) {
      root->add_child( _servers.index( i ).save() );
    }

    doc->set_root_element( root );
    doc->save_format_file( fname, 1 );
    delete doc;

    return( true );

  }

  /* Loads the stored XML file */
  public bool load() {

    Xml.Doc* doc = Xml.Parser.read_file( servers_filename( false ), null, Xml.ParserOption.HUGE );
    if( doc == null ) {
      return( false );
    }

    Xml.Node* root = doc->get_root_element();

    for( Xml.Node* it=root->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == Server.xml_node) ) {
        var server = new Server();
        server.load( it );
        add_server( server );
      }
    }

    delete doc;

    return( true );

  }

}
