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
    win.dir_list.selected.connect( directory_selected );

    /* Connect to the rule list signals */
    win.rule_list.enable_changed.connect( rule_enable_changed );
    win.rule_list.added.connect( rule_added );
    win.rule_list.removed.connect( rule_removed );
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
      // _current_dir = _data.get_directory( 0 );
      _win.dir_list.view.get_selection().select_path( new TreePath.first() );
    }
  }

  private void populate_dirs() {

    _win.dir_list.model.clear();

    for( int i=0; i<_data.size(); i++ ) {

      var dir = _data.get_directory( i );

      /* Add the directory information to the model */
      TreeIter it;
      _win.dir_list.model.append( out it );
      _win.dir_list.model.set( it, 0, dir.enabled, 1, dir.dirname, -1 );

    }

    /* Make sure that the welcome1 page is shown */
    _win.rule_stack.visible_child_name = "welcome1";

  }

  private void populate_rules( DirActions dir ) {

    _win.rule_list.model.clear();

    for( int j=0; j<dir.num_rules(); j++ ) {

      var rule = dir.get_rule( j );

      TreeIter it2;
      _win.rule_list.model.append( out it2 );
      _win.rule_list.model.set( it2, 0, rule.enabled, 1, rule.name, -1 );
  
    }

    /* Make sure that the welcome2 page is shown */
    _win.rule_stack.visible_child_name = "welcome2";

  }

  // =========================================================
  // DIRECTORY LIST
  // =========================================================

  private void directory_enable_changed( TreeView view, Gtk.ListStore model, TreePath path ) {

    /* Get the iterator associated with the model */
    TreeIter it;
    if( !model.get_iter( out it, path ) ) return;

    string? dirname = null;
    model.get( it, 1, &dirname, -1 );

    /* Update the model */
    if( dirname != null ) {
      var dir = _data.find_directory( dirname );
      if( dir != null ) {
        dir.enabled = !dir.enabled;
        model.set( it, 0, dir.enabled, -1 );
      }
    }

  }

  /* Called whenever a new directory is attempted to be added */
  private void directory_added( TreeView view, Gtk.ListStore model, string pathname ) {

    /* Create a new directory action */
    var dir = new DirActions.with_directory( pathname );
    if( !_data.add_directory( dir ) ) return;

    /* Update the treeview model */
    TreeIter it;
    model.append( out it );
    model.set( it, 0, dir.enabled, 1, dir.dirname, -1 );

  }

  /* Called whenever a directory is removed from the UI */
  private void directory_removed( TreeView view, Gtk.ListStore model ) {

    TreeIter it;
    var dir = get_selected_directory( view, model, out it );
    if( dir == null ) return;

    /* Delete the directory */
    _data.remove_directory( dir );

    /* Update the treeview model */
    model.remove( ref it );

  }

  private DirActions? get_selected_directory( TreeView view, Gtk.ListStore model, out TreeIter it ) {

    /* Get the selected directory row */
    if( !view.get_selection().get_selected( null, out it ) ) return( null );

    /* Get the stored directory name */
    string? dirname = null;
    model.get( it, 1, &dirname, -1 );

    /* Remove the selected directory from the structures */
    return( (dirname == null) ? null : _data.find_directory( dirname ) );

  }

  /* Called whenever a directory selection changes in the UI */
  private void directory_selected( TreeView view, Gtk.ListStore model ) {

    TreeIter it;
    var dir = get_selected_directory( view, model, out it );

    if( dir == null ) {

      /* Clear the rule list */
      _win.rule_list.model.clear();

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

  private void rule_enable_changed( TreeView view, Gtk.ListStore model, TreePath path ) {

    /* Get the iterator associated with the model */
    TreeIter it;
    if( !model.get_iter( out it, path ) ) return;

    string? name = null;
    model.get( it, 1, &name, -1 );

    /* Update the model */
    if( name != null ) {
      var rule = _current_dir.find_rule( name );
      if( rule != null ) {
        rule.enabled = !rule.enabled;
        model.set( it, 0, rule.enabled, -1 );
      }
    }

  }

  private void rule_added( TreeView view, Gtk.ListStore model, string name ) {

    /* Create a new directory action */
    var rule = new DirAction.with_name( name );
    if( !_current_dir.add_rule( rule ) ) {
      return;
    }

    /* Update the treeview model */
    TreeIter it;
    model.append( out it );
    model.set( it, 0, rule.enabled, 1, rule.name, -1 );

    /* Select the newly added row */
    view.get_selection().select_iter( it );

  }

  private void rule_removed( TreeView view, Gtk.ListStore model ) {

    TreeIter it;
    var rule = get_selected_rule( view, model, out it );
    if( rule == null ) return;

    /* Delete the directory */
    _current_dir.remove_rule( rule );

    /* Update the treeview model */
    model.remove( ref it );

  }

  private DirAction? get_selected_rule( TreeView view, Gtk.ListStore model, out TreeIter it ) {

    /* Get the selected directory row */
    if( !view.get_selection().get_selected( null, out it ) ) return( null );

    /* Get the stored directory name */
    string? rule = null;
    model.get( it, 1, &rule, -1 );

    /* Remove the selected directory from the structures */
    return( (rule == null) ? null : _current_dir.find_rule( rule ) );

  }

  private void rule_selected( TreeView view, Gtk.ListStore model ) {

    TreeIter it;
    var rule = get_selected_rule( view, model, out it );

    if( rule == null ) {

      _win.rule_stack.visible_child_name = "welcome1";

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

    TreeIter it;
    _win.rule_list.view.get_selection().get_selected( null, out it );

    /* Update the rule list item */
    _win.rule_list.model.set( it, 1, rule.name, -1 );

    /* Copy the rule into the current rule */
    _current_rule.copy( rule );

    /* Clear the list selection */
    _win.rule_list.view.get_selection().unselect_iter( it );

    /* Save the content */
    _data.save();

    /* Display the welcome2 banner */
    _win.rule_stack.visible_child_name = "welcome2";

  }

  private void form_cancelled() {

    TreeIter it;
    _win.rule_list.view.get_selection().get_selected( null, out it );
    _win.rule_list.view.get_selection().unselect_iter( it );

    _win.rule_stack.visible_child_name = "welcome2";

  }

}
