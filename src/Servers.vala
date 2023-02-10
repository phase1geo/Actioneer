public class Servers {

  public static const string xml_node = "servers";

  Array<Server> _servers;

  /* Default constructor */
  public Servers() {
    _servers = new Array<Server>();
  }

  public int num_servers() {
    return( (int)_servers.length );
  }

  public void add_server( Server server ) {
    _servers.append_val( server );
  }

  public Server get_server( int index ) {
    return( _servers.index( index ) );
  }

  public void remove_server( int index ) {
    _servers.remove_index( index );
  }

  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    for( int i=0; i<_servers.length; i++ ) {
      node->add_child( _servers.index( i ).save() );
    }

    return( node );

  }

  public void load( Xml.Node* node ) {

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == Server.xml_node) ) {
        var server = new Server();
        server.load( it );
        add_server( server );
      }
    }

  }

}
