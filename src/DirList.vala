public class DirList {

  private SList<DirActions> _dir_actions;

  public bool        background_enabled { set; get; default = true; }
  public DirActions? current_dir        { set; get; default = null; }

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

  public void move_directory( DirActions dir, int to ) {
    _dir_actions.remove( dir );
    _dir_actions.insert( dir, to );
  }

  /* Run the actions for each listed directory */
  public void run( GLib.Application app ) {
    if( background_enabled ) {
      _dir_actions.foreach((action) => {
        action.run( app );
      });
    }
  }

  /* Returns the rules.xml complete filepath */
  private string? rules_filename( bool create_if_nonexistent ) {

    var dir = GLib.Path.build_filename( Environment.get_user_data_dir(), "actioneer" );
    if( create_if_nonexistent && (DirUtils.create_with_parents( dir, 0775 ) != 0) ) {
      return( null );
    }

    return( GLib.Path.build_filename( dir, "rules.xml" ) );

  }

  /* Returns true if any directory actions contain actions using the given server */
  public bool server_in_use( string name ) {
    for( int i=0; i<_dir_actions.length(); i++ ) {
      if( _dir_actions.nth_data( i ).server_in_use( name ) ) {
        return( true );
      }
    }
    return( false );
  }

  // --------------------------------------------------------
  // SEARCH
  // --------------------------------------------------------

  /* Clears the current search items */
  public void clear_search() {
    _dir_actions.foreach((action) => {
      action.clear_search();
    });
  }

  /* Performs the search given the search criteria */
  public void do_search( SearchCriteria criteria ) {
    _dir_actions.foreach((action) => {
      action.do_search( criteria );
    });
  }
  
  // --------------------------------------------------------
  // SAVE/LOAD
  // --------------------------------------------------------

  /* Saves the rules.xml file to the filesystem */
  public bool save() {

    var rules = rules_filename( true );
    if( rules == null ) {
      return( false );
    }

    Xml.Doc*  doc  = new Xml.Doc( "1.0" );
    Xml.Node* root = new Xml.Node( null, "actioneer-rules" );

    root->set_prop( "version", Actioneer.version );
    root->set_prop( "background-enable", background_enabled.to_string() );

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

    var be = root->get_prop( "background-enable" );
    if( be != null ) {
      background_enabled = bool.parse( be );
    }

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
