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
  private Hdy.HeaderBar   _left_header;
  private Hdy.HeaderBar   _right_header;
  private Switch          _enable;
  private Gtk.AccelGroup? _accel_group = null;
  private DirectoryList   _dir_list;
  private RuleList        _rule_list;
  private RuleStack       _rule_stack;
  private PinList         _pin_list;
  private Stack           _list_stack;
  private Button          _server_btn;

  private const GLib.ActionEntry[] action_entries = {
    { "action_add_dir",   action_add_dir },
    { "action_add_rule",  action_add_rule },
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

  public PinList pin_list {
    get {
      return( _pin_list );
    }
  }

  public RuleStack rule_stack {
    get {
      return( _rule_stack );
    }
  }

  public signal void background_toggled();

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
    _left_header = new Hdy.HeaderBar();
    _left_header.set_show_close_button( false );
    populate_left_header();

    _dir_list   = new DirectoryList( this );
    _rule_list  = new RuleList( this );
    _rule_stack = new RuleStack( this );
    _pin_list   = new PinList( this );

    /* Create list pane (contains directory and rule lists */
    var list_pane = new Paned( Orientation.HORIZONTAL );
    list_pane.pack1( _dir_list,  true, false );
    list_pane.pack2( _rule_list, true, false );

    _list_stack = new Stack();
    _list_stack.add_named( list_pane, "dir_rules" );
    _list_stack.add_named( _pin_list, "pin_rules" );

    var left_panel = new Box( Orientation.VERTICAL, 0 );
    left_panel.pack_start( _left_header, false, true, 0 );
    left_panel.pack_start( _list_stack,  true,  true, 0 );

    _right_header = new Hdy.HeaderBar();
    _right_header.set_show_close_button( true );
    populate_right_header();

    var right_panel = new Box( Orientation.VERTICAL, 0 );
    right_panel.pack_start( _right_header, false, true, 0 );
    right_panel.pack_start( _rule_stack,  true,  true, 0 );

    var top_pane = new Paned( Orientation.HORIZONTAL );
    top_pane.pack1( left_panel,  true, true );
    top_pane.pack2( right_panel, true, true );

    /* Display the UI */
    add( top_pane );
    show_all();

    /* Make sure that the directory rules are shown by default */
    _list_stack.set_visible_child_name( "dir_rules" );

    /* Create UI styles */
    CssProvider provider = new CssProvider();
    try {
      // var css_data = ".enablelist-selected { background: #087DFF; }";
      var css_data = ".enablelist-selected { background: #C0E0FF; } " +
                     ".rulelist-droppable  { border-color: #00ff00; border-style: solid; } " +
                     ".enablelist-padding { " +
                     "  padding-top: 5px; " + 
                     "  padding-bottom: 5px; " +
                     "  padding-left: 10px; " +
                     "  padding-right: 10px; " +
                     "  border-width: 2px; " +
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

    app.set_accels_for_action( "win.action_add_dir",   { "<Control>o" } );
    app.set_accels_for_action( "win.action_add_rule",  { "<Control>n" } );
    app.set_accels_for_action( "win.action_run",       { "<Control>r" } );
    app.set_accels_for_action( "win.action_quit",      { "<Control>q" } );
    app.set_accels_for_action( "win.action_prefs",     { "<Control>comma" } );
    app.set_accels_for_action( "win.action_shortcuts", { "<Control>question" } );

  }

  /* Add widgets to header bar */
  private void populate_left_header() {

    _enable = new Switch();
    _enable.set_tooltip_text( _( "Background processor enable" ) );
    _enable.button_press_event.connect((e) => {
      background_toggled();
      return( false );
    });
    _left_header.pack_start( _enable );

    var lbl = new Label( "  " );
    _left_header.pack_start( lbl );

    var run_btn = new Button.from_icon_name( "media-playback-start", IconSize.LARGE_TOOLBAR );
    run_btn.set_tooltip_markup( Utils.tooltip_with_accel( _( "Run Rules" ), "<Control>r" ) );
    run_btn.add_accelerator( "clicked", _accel_group, 'r', Gdk.ModifierType.CONTROL_MASK, AccelFlags.VISIBLE );
    run_btn.clicked.connect( action_run );
    _left_header.pack_start( run_btn );

    var pin_btn = new ToggleButton();
    pin_btn.image = new Image.from_icon_name( "view-pin-symbolic", IconSize.LARGE_TOOLBAR );
    pin_btn.set_tooltip_text( _( "Show Pinned Rules" ) );
    pin_btn.toggled.connect( action_toggle_pin_view );
    _left_header.pack_end( pin_btn );

  }

  private void populate_right_header() {

    _server_btn = new Button.from_icon_name( "network-server-symbolic", IconSize.LARGE_TOOLBAR );
    _server_btn.set_tooltip_text( _( "Manage servers" ) );
    _server_btn.clicked.connect( action_show_servers );
    _right_header.pack_end( _server_btn );

  }

  public Actioneer get_app() {
    Actioneer? app = null;
    @get( "application", ref app );
    return( app );
  }

  private void action_add_dir() {
    _dir_list.action_add();
  }

  private void action_add_rule() {
    if( get_app().dirlist.current_dir != null ) {
      _rule_list.action_add();
    }
  }

  /* Called when the user uses Control-r keyboard shortcut to run the current actions */
  private void action_run() {
    var app = get_app();
    app.dirlist.run( app );
  }

  /* Toggles the pin view */
  private void action_toggle_pin_view() {
    if( _list_stack.get_visible_child_name() == "dir_rules" ) {
      _list_stack.set_visible_child_name( "pin_rules" );
      _rule_stack.visible_child_name = "pinned";
    } else {
      _list_stack.set_visible_child_name( "dir_rules" );
      _rule_stack.visible_child_name = "welcome1";
    }
  }

  private void action_show_servers() {

    var servers = get_app().dirlist.servers;

    var create = new Gtk.MenuItem.with_label( "Add Server" );
    create.activate.connect(() => {
      edit_server( servers, null );
    });

    var menu = new Gtk.Menu();
    menu.add( create );
    if( servers.num() > 0 ) {
      menu.add( new SeparatorMenuItem() );
    }

    for( int i=0; i<servers.num(); i++ ) {
      var server = servers.get_server( i );
      var item   = new Gtk.MenuItem.with_label( server.name );
      item.activate.connect(() => {
        edit_server( servers, server );
      });
      menu.add( item );
    }

    menu.show_all();
    menu.popup_at_widget( _server_btn, Gravity.SOUTH, Gravity.NORTH );

  }

  private void edit_server( Servers servers, Server? server ) {

    var win = new Gtk.Window();
    win.title = (server == null) ? _( "Add Server" ) : _( "Edit Server" );
    win.destroy_with_parent = true;
    win.accept_focus = true;
    win.modal = true;
    win.resizable = false;
    win.transient_for = this;
    win.border_width = 10;

    var name_label = new Label( _( "Name:" ) );
    var name_entry = new Entry();
    var host_label = new Label( _( "Host URL:" ) );
    var host_entry = new Entry();
    var conn_label = new Label( _( "Type:" ) );
    var conn_mb    = new ServerConnOptMenu();
    var port_label = new Label( _( "Port:" ) );
    var port_entry = new Entry();
    var user_label = new Label( _( "Username:" ) );
    var user_entry = new Entry();
    var pass_label = new Label( _( "Password:" ) );
    var pass_entry = new Entry();
    var pass_info  = new Label( _( "Passwords are saved in your system keyring" ) );
    var err_info   = new Label( "" );

    name_label.halign = Align.END;
    conn_label.halign = Align.END;
    host_label.halign = Align.END;
    port_label.halign = Align.END;
    user_label.halign = Align.END;
    pass_label.halign = Align.END;

    host_entry.input_purpose   = InputPurpose.URL;
    port_entry.input_purpose   = InputPurpose.DIGITS;
    port_entry.max_width_chars = 5;
    pass_entry.input_purpose   = InputPurpose.PASSWORD;
    pass_entry.visibility      = false;

    var grid = new Grid();
    grid.column_spacing = 10;
    grid.row_spacing = 10;
    grid.margin_bottom = 10;
    grid.attach( name_label, 0, 0 );
    grid.attach( name_entry, 1, 0, 3 );
    grid.attach( host_label, 0, 1 );
    grid.attach( host_entry, 1, 1, 3 );
    grid.attach( conn_label, 0, 2 );
    grid.attach( conn_mb,    1, 2 );
    grid.attach( port_label, 2, 2 );
    grid.attach( port_entry, 3, 2 );
    grid.attach( user_label, 0, 3 );
    grid.attach( user_entry, 1, 3, 3 );
    grid.attach( pass_label, 0, 4 );
    grid.attach( pass_entry, 1, 4, 3 );
    grid.attach( pass_info,  1, 5, 3 );
    grid.attach( err_info,   0, 6, 4 );

    var bbar = new Box( Orientation.HORIZONTAL, 10 );

    /*
     Add delete button if we are editing a server that is not being
     referenced by any actions.
    */
    if( server != null ) {
      var del = new Button.with_label( _( "Delete" ) );
      del.clicked.connect(() => {
        servers.remove_server_by_name( server.name );
      });
      bbar.pack_start( del, false, false, 0 );
    }

    /* Add test and save button */
    var save = new Button.with_label( _( "Test and Save" ) );
    save.sensitive = false;
    save.get_style_context().add_class( "suggested-action" );
    save.clicked.connect(() => {
      var new_server = (server == null) ? new Server() : server;
      new_server.store(
        name_entry.text,
        (ServerConnectType)conn_mb.get_current_item(),
        host_entry.text,
        int.parse( port_entry.text ),
        user_entry.text,
        pass_entry.text
      );
      new_server.test.begin( this, (obj, res) => {
        if( new_server.test.end( res ) ) {
          if( server == null ) {
            servers.add_server( new_server );
          }
          get_app().dirlist.save();
          win.close();
        } else {
          new_server.unstore();
          err_info.label = _( "Unable to connect to server" );
        }
      });
    });
    bbar.pack_end( save, false, false, 0 );

    /* Add cancel editing button */
    var cancel = new Button.with_label( _( "Cancel" ) );
    cancel.clicked.connect(() => {
      win.close();
    });
    bbar.pack_end( cancel, false, false, 0 );

    var box = new Box( Orientation.VERTICAL, 10 );
    box.pack_start( grid, true,  true, 0 );
    box.pack_start( bbar, false, true, 0 );

    name_entry.insert_text.connect((str, len, ref pos) => {
      validate( save, str, host_entry.text, port_entry.text, user_entry.text, pass_entry.text );
    });
    host_entry.insert_text.connect((str, len, ref pos) => {
      validate( save, name_entry.text, str, port_entry.text, user_entry.text, pass_entry.text );
    });
    port_entry.insert_text.connect((str, len, ref pos) => {
      handle_insert_digit( port_entry, str, len, ref pos );
      validate( save, name_entry.text, host_entry.text, port_entry.text, user_entry.text, pass_entry.text );
    });
    user_entry.insert_text.connect((str, len, ref pos) => {
      handle_insert_nospace( user_entry, str, len, ref pos );
      validate( save, name_entry.text, host_entry.text, port_entry.text, user_entry.text, pass_entry.text );
    });
    pass_entry.insert_text.connect((str, len, ref pos) => {
      handle_insert_nospace( pass_entry, str, len, ref pos );
      validate( save, name_entry.text, host_entry.text, port_entry.text, user_entry.text, pass_entry.text );
    });
    conn_mb.activated.connect((index) => {
      var type = (ServerConnectType)index;
      port_entry.text = type.port().to_string();
    });

    if( server != null ) {
      name_entry.text = server.name;
      conn_mb.set_current_item( (int)server.conn_type );
      host_entry.text = server.host;
      port_entry.text = server.port.to_string();
      user_entry.text = server.user;
      pass_entry.text = server.get_password() ?? "";
      validate( save, name_entry.text, host_entry.text, port_entry.text, user_entry.text, pass_entry.text );
    } else {
      conn_mb.set_current_item( 0 );
    }

    win.add( box );
    win.show_all();

  }

  private void handle_insert_digit( Entry entry, string str, int len, ref int pos ) {
    var result = "";
    for( int i=0; i<len; i++ ) {
      if( !str.valid_char( i ) || !str.get_char( i ).isdigit() ) {
        continue;
      }
      result += str.get_char( i ).to_string();
    }
    if( str != result ) {
      SignalHandler.block_by_func( (void*)entry, (void*)handle_insert_digit, this );
      entry.insert_text( result, result.length, ref pos );
      SignalHandler.unblock_by_func( (void*)entry, (void*)handle_insert_digit, this );
      Signal.stop_emission_by_name( entry, "insert_text" );
    }
  }

  private void handle_insert_nospace( Entry entry, string str, int len, ref int pos ) {
    var result = "";
    for( int i=0; i<len; i++ ) {
      if( !str.valid_char( i ) || str.get_char( i ).isspace() ) {
        continue;
      }
      result += str.get_char( i ).to_string();
    }
    if( str != result ) {
      SignalHandler.block_by_func( (void*)entry, (void*)handle_insert_nospace, this );
      entry.insert_text( result, result.length, ref pos );
      SignalHandler.unblock_by_func( (void*)entry, (void*)handle_insert_nospace, this );
      Signal.stop_emission_by_name( entry, "insert_text" );
    }
  }

  private void validate( Button save, string name, string host, string port, string user, string pass ) {
    save.sensitive = (name != "") && (host != "") && (port != "") && (user != "") && (pass != "");
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

  public void set_background_enable( bool enable ) {
    _enable.set_active( enable );
  }

}

