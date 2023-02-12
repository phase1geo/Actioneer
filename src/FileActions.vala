public class FileActions {

  public static const string xml_node = "file-actions";

  private SList<FileAction> _actions;

  /* Default constructor */
  public FileActions() {
    _actions = new SList<FileAction>();
  }

  public void copy( FileActions other ) {
    _actions = new SList<FileAction>();
    other._actions.foreach((action) => {
      _actions.append( new FileAction.copy( action ) );
    });
  }

  /* Returns the number of stored file actions */
  public int size() {
    return( (int)_actions.length() );
  }

  /* Returns the action at the specified index */
  public FileAction get_action( int index ) {
    return( _actions.nth_data( index ) );
  }

  /* Adds the given file action to the list */
  public void add( FileAction action ) {
    _actions.append( action );
  }

  public void remove( FileAction action ) {
    _actions.remove( action );
  }

  /* Executes all of the actions in serial order */
  public async void execute( GLib.Application app, string pathname ) {
    string? path = pathname;
    for( int i=0; i<(int)_actions.length; i++ ) {
      if( path != null ) {
        path = yield _actions.nth_data( i ).execute( app, path );
      }
    }
  }

  /* Saves this instance in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    _actions.foreach((action) => {
      node->add_child( action.save() );
    });

    return( node );

  }

  /* Loads the XML formatted description of this instance into this instance */
  public void load( Xml.Node* node ) {

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == FileAction.xml_node) ) {
        var action = new FileAction();
        action.load( it );
        _actions.append( action );
      }
    }

  }

}
