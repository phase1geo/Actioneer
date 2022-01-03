public class FileActions {

  public static string xml_node = "file-actions";

  private SList<FileAction> _actions;

  /* Default constructor */
  public FileActions() {
    _actions = new SList<FileAction>();
  }

  /* Executes all of the actions in serial order */
  public bool execute( string dirname ) {
    _actions.foreach((action) => {
      action.execute( dirname );
    });
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
