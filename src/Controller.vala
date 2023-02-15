using Gtk;

public class Controller {

  private MainWindow _win;
  private DirList    _data;
  private bool       _search_mode;
  private string     _search_text;

  /* Default constructor */
  public Controller( MainWindow win, DirList data ) {

    _win         = win;
    _data        = data;
    _search_mode = false;
    _search_text = "";

    /* Connect to the main window signals */
    win.background_toggled.connect( background_enable_changed );
    win.search_toggled.connect( search_toggled );
    win.search_changed.connect( search_changed );

    /* Connect to the directory list signals */
    win.dir_list.enable_changed.connect( directory_enable_changed );
    win.dir_list.added.connect( directory_added );
    win.dir_list.removed.connect( directory_removed );
    win.dir_list.moved.connect( directory_moved );
    win.dir_list.selected.connect( directory_selected );

    /* Connect to the rule list signals */
    win.rule_list.enable_changed.connect( rule_enable_changed );
    win.rule_list.added.connect( rule_added );
    win.rule_list.removed.connect( rule_removed );
    win.rule_list.moved.connect( rule_moved );
    win.rule_list.selected.connect( rule_selected );
    win.rule_list.execute.connect( rule_execute );
    win.rule_list.duplicated.connect( rule_duplicated );
    win.rule_list.move_rule.connect( rule_move_to_directory );
    win.rule_list.copy_rule.connect( rule_move_to_directory );

    /* Connect to the pin list signals */
    win.pin_list.removed.connect( pin_removed );
    win.pin_list.moved.connect( pin_moved );
    win.pin_list.selected.connect( pin_selected );
    win.pin_list.execute.connect( pin_execute );

    /* Connect to the rule form */
    win.rule_stack.form.save_requested.connect( form_save );
    win.rule_stack.form.cancel_requested.connect( form_cancelled );

    initialize();

  }

  /* Called when the UI is ready to have its model updated */
  private void initialize() {
    _win.set_background_enable( _data.background_enabled );
    populate_dirs();
    populate_pinned();
    if( _data.size() > 0 ) {
      _win.dir_list.select_row( 0 );
      directory_selected( 0 );
    }
  }

  private void populate_dirs() {

    _win.dir_list.clear();

    for( int i=0; i<_data.size(); i++ ) {
      var dir = _data.get_directory( i );
      _win.dir_list.add_row( dir.enabled, dir.dirname );
    }

    /* Make sure that the welcome1 page is shown */
    _win.rule_stack.visible_child_name = "welcome1";

  }

  private void populate_rules( DirActions dir ) {

    _win.rule_list.clear();

    for( int j=0; j<dir.num_rules(); j++ ) {
      var rule = dir.get_rule( j );
      _win.rule_list.add_row( rule.enabled, rule.name );
    }

    /* Make sure that the welcome2 page is shown */
    _win.rule_stack.visible_child_name = "welcome2";

  }

  private void populate_pinned() {

    _win.pin_list.clear();

    for( int i=0; i<_data.size(); i++ ) {
      var dir = _data.get_directory( i );
      for( int j=0; j<dir.num_rules(); j++ ) {
        var rule = dir.get_rule( j );
        if( rule.pinned ) {
          _win.pin_list.add_row( false, rule.name );
        }
      }
    }

  }

  // =========================================================
  // MAIN WINDOW
  // =========================================================

  private void background_enable_changed() {

    _data.background_enabled = !_data.background_enabled;

    /* Save the changes immediately */
    _data.save();

  }

  // =========================================================
  // DIRECTORY LIST
  // =========================================================

  private void directory_enable_changed( int index ) {

    var dir = _data.get_directory( index );
    dir.enabled = !dir.enabled;

    /* Save the changes immediately */
    _data.save();

  }

  /* Called whenever a new directory is attempted to be added */
  private bool directory_added( string pathname ) {
    var dir = new DirActions.with_directory( pathname );
    return( _data.add_directory( dir ) );
  }

  /* Called whenever a directory is removed from the UI */
  private void directory_removed( int index ) {

    var dir = _data.get_directory( index );

    /* Delete the directory */
    _data.remove_directory( dir );

    /* Save the change */
    _data.save();

  }

  private void directory_moved( int from, int to ) {
    var dir = _data.get_directory( from );
    _data.move_directory( dir, to );
  }

  /* Called whenever a directory selection changes in the UI */
  private void directory_selected( int index ) {

    var dir = (index == -1) ? null : _data.get_directory( index );

    if( dir == null ) {

      /* Clear the rule list */
      _win.rule_list.clear();

      /* Show the welcome1 stack page */
      _win.rule_stack.visible_child_name = "welcome1";

    } else if( dir != _data.current_dir ) {

      /* Update the rule list */
      populate_rules( dir );

    }

    /* Save the currently selected directory */
    _data.current_dir = dir;

  }

  // =========================================================
  // RULE LIST
  // =========================================================

  private void rule_enable_changed( int index ) {

    var rule = _data.current_dir.get_rule( index );
    rule.enabled = !rule.enabled;

    /* Save the data immediately */
    _data.save();

  }

  private bool rule_added( string name ) {

    var rule = new DirAction.with_name( name );

    return( _data.current_dir.add_rule( rule ) );

  }

  private bool rule_duplicated( int index, ref bool enable, ref string label ) {

    var old_rule = _data.current_dir.get_rule( index );
    var cpy_name = old_rule.name + " " + _( "Copy" );
    var idx      = 2;

    enable = old_rule.enabled;
    label  = cpy_name;

    while( _data.current_dir.find_rule( label ) != null ) {
      label = cpy_name + " " + idx.to_string();
    }

    var new_rule = new DirAction();
    new_rule.copy( old_rule, label );

    return( _data.current_dir.add_rule( new_rule ) );

  }

  private void rule_removed( int index ) {

    var rule = _data.current_dir.get_rule( index );

    /* Delete the rule */
    _data.current_dir.remove_rule( rule );

    /* Save the change */
    _data.save();

  }

  private void rule_moved( int from, int to ) {

    var rule = _data.current_dir.get_rule( from );

    _data.current_dir.move_rule( rule, to );

  }

  private void rule_move_to_directory( int rule_index, int dir_index ) {

    var rule = _data.current_dir.get_rule( rule_index );

    /* Remove the rule from the current directory */
    _data.current_dir.remove_rule( rule );

    /* Add the rule to the dir_index directory */
    var dir = _data.get_directory( dir_index );
    dir.add_rule( rule );

  }

  private void rule_copy_to_directory( int rule_index, int dir_index ) {

    var rule = _data.current_dir.get_rule( rule_index );
    var rule_copy = new DirAction();
    rule_copy.copy( rule );

    /* Add the rule to the dir_index directory */
    var dir = _data.get_directory( dir_index );
    dir.add_rule( rule_copy );

  }

  private void rule_selected( int index ) {

    var rule = (index == -1) ? null : _data.current_dir.get_rule( index );

    if( rule == null ) {

      _win.rule_stack.visible_child_name = "welcome2";

    } else if( (rule != _data.current_dir.current_rule) || (_win.rule_stack.visible_child_name != "form") ) {

      _win.rule_stack.form.initialize( rule );
      _win.rule_stack.visible_child_name = "form";

    }

    /* Save the currently selected rule */
    _data.current_dir.current_rule = rule;

  }

  private void rule_execute( int index, string fname ) {

    var rule = (index == -1) ? null : _data.current_dir.get_rule( index );

    if( rule != null ) {
      rule.execute( _win.get_app(), fname );
    }

  }

  // =========================================================
  // SEARCH
  // =========================================================

  private void search_toggled() {

    /* If we are in search mode, display all directories and rules */
    if( _search_mode ) {
      _data.clear_search();
    }

    _search_mode = !_search_mode;

    stdout.printf( "CONTROLLER, search_mode: %s\n", _search_mode.to_string() );

  }

  private void search_changed( string text ) {

    _search_text = text;

  }

  // =========================================================
  // PIN LIST
  // =========================================================

  private void pin_removed( int index ) {
  }

  private void pin_moved( int from, int to ) {
  }

  private void pin_selected( int index ) {
  }
  
  private void pin_execute( int index, string path ) {
  }

  // =========================================================
  // RULE FORM
  // =========================================================

  private void form_save( DirAction rule ) {

    /*
    TreeIter it;
    _win.rule_list.view.get_selection().get_selected( null, out it );
    */

    /* Update the rule list item */
    _win.rule_list.set_label( rule.name );

    /* Copy the rule into the current rule */
    _data.current_dir.current_rule.copy( rule );

    /* Save the content */
    _data.save();

    /* Display the welcome2 banner */
    _win.rule_stack.visible_child_name = "welcome2";

  }

  private void form_cancelled() {

    /* Clear the rule selection */
    _win.rule_list.select_row( -1 );

    /* Change the panel to display welcome2 UI */
    _win.rule_stack.visible_child_name = "welcome2";

  }

}
