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
  private DirectoryList   _dir_list;
  private RuleList        _rule_list;
  private RuleStack       _rule_stack;

  private const GLib.ActionEntry[] action_entries = {
    { "action_run",       action_run },
    { "action_quit",      action_quit },
    { "action_prefs",     action_prefs },
    { "action_shortcuts", action_shortcuts }
  };

  public DirectoryList dir_list {
    get {
      return( _dir_list );
    }
  }

  public RuleList rule_list {
    get {
      return( _rule_list );
    }
  }

  public RuleStack rule_stack {
    get {
      return( _rule_stack );
    }
  }

  /* Create the main window UI */
  public MainWindow( Actioneer app, GLib.Settings settings ) {

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
    delete_event.connect(() => {
      app.dirlist.save();
      return( false );
    });

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

    /* Create left pane (contains directory and rule lists */
    var left_pane = new Paned( Orientation.HORIZONTAL );

    _dir_list   = new DirectoryList( this );
    _rule_list  = new RuleList( this );
    _rule_stack = new RuleStack( this );

    left_pane.pack1( _dir_list,  true, false );
    left_pane.pack2( _rule_list, true, false );

    var top_pane = new Paned( Orientation.HORIZONTAL );
    top_pane.pack1( left_pane,   true, true );
    top_pane.pack2( _rule_stack, true, true );

    var top_box = new Box( Orientation.VERTICAL, 0 );
    top_box.pack_start( _header,  false, true, 0 );
    top_box.pack_start( top_pane, true,  true, 0 );

    /* Display the UI */
    add( top_box );
    show_all();

    /* Create UI styles */
    CssProvider provider = new CssProvider();
    try {
      // var css_data = ".enablelist-selected { background: #087DFF; }";
      var css_data = ".enablelist-selected { background: #C0E0FF; } " +
                     ".enablelist-padding { " +
                     "  padding-top: 5px; " + 
                     "  padding-bottom: 5px; " +
                     "  padding-left: 10px; " +
                     "  padding-right: 10px; " +
                     "}";
      provider.load_from_data( css_data );
    } catch( GLib.Error e ) {
      stdout.printf( _( "Unable to load background color: %s" ), e.message );
    }

    StyleContext.add_provider_for_screen(
      Screen.get_default(),
      provider,
      STYLE_PROVIDER_PRIORITY_APPLICATION
    );

  }

  static construct {
    Hdy.init();
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
    app.dirlist.run( app );
  }

  /* Called when the user uses the Control-q keyboard shortcut */
  private void action_quit() {
    destroy();
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
      app.send_notification( "com.github.phase1geo.actioneer", notification );
    }
  }

}

