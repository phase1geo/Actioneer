using Gtk;

public class Controller {

  private MainWindow _win;
  private DirList    _data;
  private DirActions _current_dir  = null;
  private DirAction  _current_rule = null;

  /* Default constructor */
  public Controller( MainWindow win, DirList data ) {

    _win  = win;
    _data = data;

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

    /* Connect to the rule form */
    win.rule_stack.form.save_requested.connect( form_save );
    win.rule_stack.form.cancel_requested.connect( form_cancelled );

    initialize();

  }

  /* Called when the UI is ready to have its model updated */
  private void initialize() {
    populate_dirs();
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

    } else if( dir != _current_dir ) {

      /* Update the rule list */
      populate_rules( dir );

    }

    /* Save the currently selected directory */
    _current_dir = dir;

  }

  // =========================================================
  // RULE LIST
  // =========================================================

  private void rule_enable_changed( int index ) {

    var rule = _current_dir.get_rule( index );
    rule.enabled = !rule.enabled;

    /* Save the data immediately */
    _data.save();

  }

  private bool rule_added( string name ) {

    var rule = new DirAction.with_name( name );

    return( _current_dir.add_rule( rule ) );

  }

  private void rule_removed( int index ) {

    var rule = _current_dir.get_rule( index );

    /* Delete the rule */
    _current_dir.remove_rule( rule );

    /* Save the change */
    _data.save();

  }

  private void rule_moved( int from, int to ) {

    var rule = _current_dir.get_rule( from );

    _current_dir.move_rule( rule, to );

  }

  private void rule_selected( int index ) {

    var rule = (index == -1) ? null : _current_dir.get_rule( index );

    if( rule == null ) {

      _win.rule_stack.visible_child_name = "welcome2";

    } else if( (rule != _current_rule) || (_win.rule_stack.visible_child_name != "form") ) {

      _win.rule_stack.form.initialize( rule );
      _win.rule_stack.visible_child_name = "form";

    }

    /* Save the currently selected rule */
    _current_rule = rule;

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
    _current_rule.copy( rule );

    /* Clear the list selection */
    // _win.rule_list.view.get_selection().unselect_iter( it );

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
