 /*
* Copyright (c) 2018 (https://github.com/phase1geo/Minder)
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

  private GLib.Settings     _settings;
  private Hdy.HeaderBar     _header;
  private Gtk.AccelGroup?   _accel_group = null;

  private const GLib.ActionEntry[] action_entries = {
    { "action_quit",      action_quit },
    { "action_prefs",     action_prefs },
    { "action_shortcuts", action_shortcuts }
  };

  public GLib.Settings settings {
    get {
      return( _settings );
    }
  }

  /* Create the main window UI */
  public MainWindow( Gtk.Application app, GLib.Settings settings ) {

    Object( application: app );

    _settings = settings;

    var window_x = settings.get_int( "window-x" );
    var window_y = settings.get_int( "window-y" );
    var window_w = settings.get_int( "window-w" );
    var window_h = settings.get_int( "window-h" );

    /* Create the header bar */
    _header = new Hdy.HeaderBar();
    _header.set_show_close_button( true );

    /* Set the main window data */
    title = _( "Actioneer" );
    set_default_size( window_w, window_h );
    destroy.connect( Gtk.main_quit );

    /* Set the stage for menu actions */
    var actions = new SimpleActionGroup ();
    actions.add_action_entries( action_entries, this );
    insert_action_group( "win", actions );

    /* Create the accelerator group for the window */
    _accel_group = new Gtk.AccelGroup();
    this.add_accel_group( _accel_group );

    /* Add keyboard shortcuts */
    add_keyboard_shortcuts( app );

    /* TBD - Create title toolbar */

    var top_box = new Box( Orientation.VERTICAL, 0 );
    top_box.pack_start( _header, false, true, 0 );
    // top_box.pack_start( _pane, true, true, 0 );

    /* Display the UI */
    add( top_box );
    show_all();

  }

  static construct {
    Hdy.init();
  }

  /* Adds keyboard shortcuts for the menu actions */
  private void add_keyboard_shortcuts( Gtk.Application app ) {

    app.set_accels_for_action( "win.action_quit",      { "<Control>q" } );
    app.set_accels_for_action( "win.action_prefs",     { "<Control>comma" } );
    app.set_accels_for_action( "win.action_shortcuts", { "<Control>question" } );

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
      app.send_notification( "com.github.phase1geo.minder", notification );
    }
  }

}

