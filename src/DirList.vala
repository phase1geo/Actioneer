public class DirList {

  private DirActions _dir_actions;

  /* Default constructor */
  public DirList() {

    _dir_actions = new DirActions();

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

    root->add_child( _dir_actions.save() );

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
        _dir_actions.load( it );
        break;
      }
    }

    delete doc;

    return( true );

  }

}
