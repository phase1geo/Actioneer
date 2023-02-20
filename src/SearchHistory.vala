public class SearchHistory {

  
  private SList<string> _history;

  /* Default constructor */
  public SearchHistory() {
    _history = new SList<string>();
  }

  public int size() {
    return( (int)_history.length() );
  }

  public string get_item( int index ) {
    return( _history.nth_data( index ) );
  }

  public void add_item( string text ) {
    if( text != "" ) {
      var depth = Actioneer.settings.get_int( "search-history-depth" );
      _history.remove( text );
      if( _history.length() == depth ) {
        _history.remove( _history.nth_data( depth - 1 ) );
      }
      _history.prepend( text );
      save();
    }
  }

  /* Returns the rules.xml complete filepath */
  private string? history_filename( bool create_if_nonexistent ) {

    var dir = GLib.Path.build_filename( Environment.get_user_data_dir(), "actioneer" );
    if( create_if_nonexistent && (DirUtils.create_with_parents( dir, 0775 ) != 0) ) {
      return( null );
    }

    return( GLib.Path.build_filename( dir, "search.xml" ) );

  }

  public bool save() {

    var fname = history_filename( true );
    if( fname == null ) {
      return( false );
    }

    Xml.Doc*  doc  = new Xml.Doc( "1.0" );
    Xml.Node* root = new Xml.Node( null, "actioneer-search" );

    root->set_prop( "version", Actioneer.version );

    _history.foreach((text) => {
      Xml.Node* node = new Xml.Node( null, "entry" );
      node->set_prop( "text", text );
      root->add_child( node );
    });

    doc->set_root_element( root );
    doc->save_format_file( fname, 1 );
    delete doc;

    return( true );

  }

  /* Loads the stored XML file */
  public bool load() {

    Xml.Doc* doc = Xml.Parser.read_file( history_filename( false ), null, Xml.ParserOption.HUGE );
    if( doc == null ) {
      return( false );
    }

    Xml.Node* root = doc->get_root_element();

    for( Xml.Node* it=root->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == "entry") ) {
        _history.append( it->get_prop( "text" ) );
      }
    }

    delete doc;

    return( true );


  }

}
