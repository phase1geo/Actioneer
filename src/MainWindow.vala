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
using Gdk;

public class MainWindow : Hdy.ApplicationWindow {

  private GLib.Settings   _settings;
  private Hdy.HeaderBar   _header;
  private Gtk.AccelGroup? _accel_group = null;
  private TreeView        _dir_view;
  private Gtk.ListStore   _dir_model;

  private const GLib.ActionEntry[] action_entries = {
    { "action_run",       action_run },
    { "action_quit",      action_quit },
    { "action_prefs",     action_prefs },
    { "action_shortcuts", action_shortcuts }
  };

  public Gtk.ListStore dir_model {
    get {
      return( _dir_model );
    }
  }

  public GLib.Settings settings {
    get {
      return( _settings );
    }
  }

  public signal void dir_enable_changed( TreeView view, Gtk.ListStore model, TreePath path );
  public signal void dir_added( TreeView view, Gtk.ListStore model, string pathname );
  public signal void dir_removed( TreeView view, Gtk.ListStore model );
  public signal void dir_selected( TreeView view, Gtk.ListStore model );

  /* Create the main window UI */
  public MainWindow( Gtk.Application app, GLib.Settings settings ) {

    Object( application: app );

    _settings = settings;

    var window_x = settings.get_int( "window-x" );
    var window_y = settings.get_int( "window-y" );
    var window_w = settings.get_int( "window-w" );
    var window_h = settings.get_int( "window-h" );

    /* Create the accelerator group for the window */
    _accel_group = new Gtk.AccelGroup();
    this.add_accel_group( _accel_group );

    /* Set the main window data */
    title = _( "Actioneer" );
    set_default_size( window_w, window_h );
    destroy.connect( Gtk.main_quit );

    /* Set the stage for menu actions */
    var actions = new SimpleActionGroup ();
    actions.add_action_entries( action_entries, this );
    insert_action_group( "win", actions );

    /* Add keyboard shortcuts */
    add_keyboard_shortcuts( app );

    /* Create the header bar */
    _header = new Hdy.HeaderBar();
    _header.set_show_close_button( true );
    populate_header();

    /* Create the directory model */
    _dir_model = new Gtk.ListStore( 2, typeof(bool), typeof(string) );

    /* Create left pane (contains directory and rule lists */
    var left_pane = new Paned( Orientation.HORIZONTAL );

    left_pane.pack1( create_directory_pane(), true, false );
    left_pane.pack2( create_rule_pane(),      true, false );

    var top_pane = new Paned( Orientation.HORIZONTAL );
    top_pane.pack1( left_pane, true, true );
    top_pane.pack2( create_content_stack(), true, true );

    var top_box = new Box( Orientation.VERTICAL, 0 );
    top_box.pack_start( _header,  false, true, 0 );
    top_box.pack_start( top_pane, true,  true, 0 );

    /* Display the UI */
    add( top_box );
    show_all();

  }

  static construct {
    Hdy.init();
  }

  private void setup_directory_list() {

    /* Add checkbox column */
    var toggle = new CellRendererToggle();
    toggle.toggled.connect((path) => {
      var tpath = new TreePath.from_string( path );
      dir_enable_changed( _dir_view, _dir_model, tpath );
    });
    var enable = new TreeViewColumn.with_attributes( null, toggle, "active", 0, null );
    enable.set_sizing( TreeViewColumnSizing.FIXED );
    enable.set_fixed_width( 50 );
    _dir_view.append_column( enable );

    /* Add directory name column */
    var text = new CellRendererText();
    var name = new TreeViewColumn.with_attributes( null, text, "text", 1, null );
    name.set_sizing( TreeViewColumnSizing.FIXED );
    name.set_fixed_width( 150 );
    _dir_view.append_column( name );

  }

  private Box create_directory_pane() {

    var lbl = new Label( _( "Directories" ) );
    lbl.margin = 10;

    /* Create button bar at the bottom of the pane */
    var add_btn = new Button.from_icon_name( "list-add-symbolic", IconSize.SMALL_TOOLBAR );
    add_btn.set_tooltip_text( _( "Add directory to manage" ) );
    add_btn.clicked.connect( action_add_directory );

    var del_btn = new Button.from_icon_name( "list-remove-symbolic", IconSize.SMALL_TOOLBAR );
    del_btn.set_tooltip_text( _( "Delete selected directory" ) );
    del_btn.set_sensitive( false );
    del_btn.clicked.connect( action_remove_directory );

    var bbox = new Box( Orientation.HORIZONTAL, 5 );
    bbox.margin = 5;
    bbox.pack_start( add_btn, false, false, 0 );
    bbox.pack_start( del_btn, false, false, 0 );

    /* Create list */
    _dir_view = new TreeView.with_model( _dir_model );
    _dir_view.headers_visible = false;
    _dir_view.get_selection().mode = SelectionMode.BROWSE;
    _dir_view.get_selection().changed.connect(() => {
      del_btn.set_sensitive( _dir_view.get_selection().get_selected( null, null ) );
      dir_selected( _dir_view, _dir_model );
    });
    setup_directory_list();

    var list_sw = new ScrolledWindow( null, null );
    list_sw.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC );
    list_sw.add( _dir_view );

    /* Pack everything in the pane */
    var box = new Box( Orientation.VERTICAL, 0 );
    box.pack_start( lbl,     false, true, 0 );
    box.pack_start( list_sw, true,  true, 0 );
    box.pack_end(   bbox,    false, true, 0 );

    return( box );

  }

  private Box create_rule_pane() {

    var box = new Box( Orientation.VERTICAL, 0 );

    return( box );

  }

  private Box create_content_stack() {

    var box = new Box( Orientation.VERTICAL, 0 );

    return( box );

  }

  /* Adds keyboard shortcuts for the menu actions */
  private void add_keyboard_shortcuts( Gtk.Application app ) {

    app.set_accels_for_action( "win.action_run",       { "<Control>r" } );
    app.set_accels_for_action( "win.action_quit",      { "<Control>q" } );
    app.set_accels_for_action( "win.action_prefs",     { "<Control>comma" } );
    app.set_accels_for_action( "win.action_shortcuts", { "<Control>question" } );

  }

  /* Add widgets to header bar */
  private void populate_header() {

    var run_btn = new Button.from_icon_name( "media-playback-start", IconSize.LARGE_TOOLBAR );
    // new_btn.set_tooltip_markup( Utils.tooltip_with_accel( _( "New File" ), "<Control>r" ) );
    run_btn.add_accelerator( "clicked", _accel_group, 'r', Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE );
    run_btn.clicked.connect( action_run );
    _header.pack_start( run_btn );

  }

  /* Called when the user uses Control-r keyboard shortcut to run the current actions */
  private void action_run() {
    Actioneer? app = null;
    @get( "application", ref app );
    app.dirlist.run();
  }

  /* Called when the user uses the Control-q keyboard shortcut */
  private void action_quit() {
    Actioneer? app = null;
    @get( "application", ref app );
    app.dirlist.save();
    destroy();
  }

  private void action_add_directory() {
    var dialog = new FileChooserNative( _( "Choose Directory" ), this, FileChooserAction.SELECT_FOLDER, _( "Choose" ), _( "Cancel" ) );
    if( dialog.run() == ResponseType.ACCEPT ) {
      dir_added( _dir_view, _dir_model, dialog.get_filename() );
    }
  }

  private void action_remove_directory() {
    dir_removed( _dir_view, _dir_model );
  }

  /* Displays the preferences dialog */
  private void action_prefs() {
    // var prefs = new Preferences( this, _settings );
    // prefs.show_all();
  }

  /* Displays the shortcuts cheatsheet */
  private void action_shortcuts() {

    var builder = new Builder.from_resource( "/com/github/phase1geo/actioneer/shortcuts.ui" );
    var win     = builder.get_object( "shortcuts" ) as ShortcutsWindow;

    win.transient_for = this;
    win.view_name     = null;

    /* Display the most relevant information based on the current state */
    win.section_name = "general";

    win.show();

  }

  /* Generate a notification */
  public void notification( string title, string msg, NotificationPriority priority = NotificationPriority.NORMAL ) {
    GLib.Application? app = null;
    @get( "application", ref app );
    if( app != null ) {
      var notification = new Notification( title );
      notification.set_body( msg );
      notification.set_priority( priority );
      app.send_notification( "com.github.phase1geo.minder", notification );
    }
  }

}

