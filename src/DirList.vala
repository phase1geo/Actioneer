public class DirList {

  private SList<DirActions> _dir_actions;

  /* Default constructor */
  public DirList() {
    _dir_actions = new SList<DirActions>();
  }

  /* Returns the number of stored directory actions */
  public int size() {
    return( (int)_dir_actions.length() );
  }

  public DirActions get_directory( int index ) {
    return( _dir_actions.nth_data( index ) );
  }

  public DirActions? find_directory( string dirname ) {
    DirActions? found = null;
    _dir_actions.foreach((action) => {
      if( action.dirname == dirname ) {
        found = action;
      }
    });
    return( found );
  }

  public bool add_directory( DirActions dir ) {
    if( find_directory( dir.dirname ) != null ) return( false );
    _dir_actions.append( dir );
    return( true );
  }

  public void remove_directory( DirActions dir ) {
    _dir_actions.remove( dir );
  }

  /* Run the actions for each listed directory */
  public void run( MainWindow win ) {
    _dir_actions.foreach((action) => {
      action.run( win );
    });
  }

  /* Returns the rules.xml complete filepath */
  private string? rules_filename( bool create_if_nonexistent ) {

    var dir = GLib.Path.build_filename( Environment.get_user_data_dir(), "actioneer" );
    if( create_if_nonexistent && (DirUtils.create_with_parents( dir, 0775 ) != 0) ) {
      return( null );
    }

    return( GLib.Path.build_filename( dir, "rules.xml" ) );

  }

  /* Saves the rules.xml file to the filesystem */
  public bool save() {

    var rules = rules_filename( true );
    if( rules == null ) {
      return( false );
    }

    Xml.Doc*  doc  = new Xml.Doc( "1.0" );
    Xml.Node* root = new Xml.Node( null, "actioneer-rules" );

    root->set_prop( "version", Actioneer.version );

    _dir_actions.foreach((action) => {
      root->add_child( action.save() );
    });

    doc->set_root_element( root );
    doc->save_format_file( rules, 1 );
    delete doc;

    return( true );

  }

  /* Loads the stored XML file */
  public bool load() {

    Xml.Doc* doc = Xml.Parser.read_file( rules_filename( false ), null, Xml.ParserOption.HUGE );
    if( doc == null ) {
      return( false );
    }

    Xml.Node* root = doc->get_root_element();

    for( Xml.Node* it=root->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == DirActions.xml_node) ) {
        var dir = new DirActions();
        dir.load( it );
        _dir_actions.append( dir );
      }
    }

    delete doc;

    return( true );

  }

}
