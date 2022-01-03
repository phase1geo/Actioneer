public class TestAction : FileAction {

  /* Default constructor */
  public TestAction() {
    base();
  }

  /* Executes the test action */
  public override bool execute( ref string pathname ) {
    stdout.printf( "Doing nothing to %s", pathname );
    return( true );
  }

  /* Saves the test action to XML format */
  public override Xml.Node* save() {
    Xml.Node* node = new Xml.Node( null, "action-test" );
    return( node );
  }

  /* Loads the test action data from XML format */
  public override void load( Xml.Node* node ) {
    // Do nothing
  }

}
