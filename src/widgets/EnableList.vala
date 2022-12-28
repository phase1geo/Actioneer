/*
* Copyright (c) 2022 (https://github.com/phase1geo/Actioneer)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Trevor Williams <phase1geo@gmail.com>
*/

using Gtk;

public class EnableList : Box {

  private TreeView      _view;
  private Gtk.ListStore _model;

  protected MainWindow  win;

  public TreeView view {
    get {
      return( _view );
    }
  }
  public Gtk.ListStore model {
    get {
      return( _model );
    }
  }

  public signal void enable_changed( TreeView view, Gtk.ListStore model, TreePath path );
  public signal void added( TreeView view, Gtk.ListStore model, string pathname );
  public signal void removed( TreeView view, Gtk.ListStore model );
  public signal void selected( TreeView view, Gtk.ListStore model );

  /* Create the main window UI */
  public EnableList( MainWindow w ) {

    Object( orientation: Orientation.VERTICAL, spacing: 0 );

    win = w;

    /* Create the directory model */
    _model = new Gtk.ListStore( 2, typeof(bool), typeof(string) );

    create_pane();

    /* Display the UI */
    show_all();

  }

  private void create_pane() {

    var lbl = new Label( title() );
    lbl.margin = 10;

    /* Create button bar at the bottom of the pane */
    var add_btn = new Button.from_icon_name( "list-add-symbolic", IconSize.SMALL_TOOLBAR );
    add_btn.set_tooltip_text( add_tooltip() );
    add_btn.clicked.connect( action_add );

    var del_btn = new Button.from_icon_name( "list-remove-symbolic", IconSize.SMALL_TOOLBAR );
    del_btn.set_tooltip_text( remove_tooltip() );
    del_btn.set_sensitive( false );
    del_btn.clicked.connect( action_remove );

    var bbox = new Box( Orientation.HORIZONTAL, 5 );
    bbox.margin = 5;
    bbox.pack_start( add_btn, false, false, 0 );
    bbox.pack_start( del_btn, false, false, 0 );

    /* Create list */
    _view = new TreeView.with_model( _model );
    _view.headers_visible = false;
    _view.reorderable = true;
    _view.get_selection().mode = select_mode();
    _view.get_selection().changed.connect(() => {
      del_btn.set_sensitive( _view.get_selection().get_selected( null, null ) );
      selected( _view, _model );
    });
    setup_list();

    var list_sw = new ScrolledWindow( null, null );
    list_sw.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC );
    list_sw.add( _view );

    /* Pack everything in the pane */
    pack_start( lbl,     false, true, 0 );
    pack_start( list_sw, true,  true, 0 );
    pack_end(   bbox,    false, true, 0 );

  }

  private void setup_list() {

    /* Add checkbox column */
    var toggle = new CellRendererToggle();
    toggle.toggled.connect((path) => {
      var tpath = new TreePath.from_string( path );
      enable_changed( _view, _model, tpath );
    });
    var enable = new TreeViewColumn.with_attributes( null, toggle, "active", 0, null );
    enable.set_sizing( TreeViewColumnSizing.FIXED );
    enable.set_fixed_width( 50 );
    _view.append_column( enable );

    /* Add directory name column */
    var text = new CellRendererText();
    var name = new TreeViewColumn.with_attributes( null, text, "text", 1, null );
    name.set_sizing( TreeViewColumnSizing.FIXED );
    name.set_fixed_width( 150 );
    _view.append_column( name );

  }

  protected virtual SelectionMode select_mode() {
    return( SelectionMode.BROWSE );
  }

  protected virtual string title() {
    assert( false );
    return( "" );
  }

  protected virtual string add_tooltip() {
    assert( false );
    return( "" );
  }

  protected virtual string remove_tooltip() {
    assert( false );
    return( "" );
  }

  public virtual void action_add() {
    assert( false );
  }

  public virtual void action_remove() {
    removed( _view, _model );
  }

}

