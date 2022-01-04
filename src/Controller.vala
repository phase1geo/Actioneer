using Gtk;

public class Controller {

  private MainWindow _win;
  private DirList    _data;

  /* Default constructor */
  public Controller( MainWindow win, DirList data ) {

    _win  = win;
    _data = data;

    win.dir_enable_changed.connect( directory_enable_changed );
    win.dir_added.connect( directory_added );
    win.dir_removed.connect( directory_removed );
    win.dir_selected.connect( directory_selected );

    initialize();

  }

  /* Called when the UI is ready to have its model updated */
  private void initialize() {

    for( int i=0; i<_data.size(); i++ ) {

      var dir = _data.get_directory( i );
      stdout.printf( "dir.enabled: %s, dir.dirname: %s\n", dir.enabled.to_string(), dir.dirname );

      /* Add the directory information to the model */
      TreeIter it;
      _win.dir_model.append( out it );
      _win.dir_model.set( it, 0, dir.enabled, 1, dir.dirname, -1 );

    }

  }

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

  private DirActions? get_selected_directory( TreeView view, Gtk.ListStore model, out TreeIter it ) {

    /* Get the selected directory row */
    view.get_selection().get_selected( null, out it );

    /* Get the stored directory name */
    string? dirname = null;
    model.get( it, 1, &dirname, -1 );

    /* Remove the selected directory from the structures */
    return( (dirname == null) ? null : _data.find_directory( dirname ) );

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

  /* Called whenever a directory selection changes in the UI */
  private void directory_selected( TreeView view, Gtk.ListStore model ) {

    TreeIter it;
    var dir = get_selected_directory( view, model, out it );
    if( dir == null ) return;

    stdout.printf( "Directory selected\n" );

  }

}
