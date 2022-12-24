 /*
* Copyright (c) 2018 (https://github.com/phase1geo/Actioneer)
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
using GLib;

public class Actioneer : Granite.Application {

  private const string INTERFACE_SCHEMA = "org.gnome.desktop.interface";

  private static bool          show_version = false;
  private static bool          run_rules    = false;
  private static bool          create       = false;
  private        GLib.Settings iface_settings;

  public         DirList       dirlist;
  public         Controller    controller;
  public  static MainWindow    appwin { get; private set; }
  public  static GLib.Settings settings;
  public  static string        version = "1.0.0";

  public Actioneer () {

    Object( application_id: "com.github.phase1geo.actioneer", flags: ApplicationFlags.HANDLES_OPEN );

    startup.connect( start_application );

  }

  private void create_data() {

    var dir    = new DirActions.with_directory( "/home/trevorw/Downloads" );
    var rule1  = new DirAction.with_name( "Trash Old Files" );
    var rule2  = new DirAction.with_name( "Move to Temporary" );
    var cond11 = new ActionCondition.with_type( ActionConditionType.MODIFY_DATE );
    var cond21 = new ActionCondition.with_type( ActionConditionType.FULLNAME );
    var cond22 = new ActionCondition.with_type( ActionConditionType.MIME );
    var act11  = new FileAction.with_filename( FileActionType.MOVE, "/home/trevorw/Documents" );
    var act21  = new FileAction.with_filename( FileActionType.MOVE, "/home/trevorw/Documents" );

    cond11.date.match_type = DateMatchType.LAST;
    cond11.date.num        = 1;
    cond11.date.time_type  = TimeType.MINUTE;

    rule1.add_condition( cond11 );
    rule1.add_action( act11 );

    cond21.text.text = "file_to_move.txt";
    cond22.text.text = "text/plain";

    rule2.add_condition( cond21 );
    rule2.add_condition( cond22 );
    rule2.add_action( act21 );

    dir.add_rule( rule1 );
    dir.add_rule( rule2 );

    dirlist.add_directory( dir );

  }

  /* First method called in the startup process */
  private void start_application() {

    /* Initialize the settings */
    settings = new GLib.Settings( "com.github.phase1geo.actioneer" );

    /* Add the application-specific icons */
    weak IconTheme default_theme = IconTheme.get_default();
    default_theme.add_resource_path( "/com/github/phase1geo/actioneer" );

    /* Add the application CSS */
    var provider = new Gtk.CssProvider ();
    provider.load_from_resource( "/com/github/phase1geo/actioneer/Application.css" );
    Gtk.StyleContext.add_provider_for_screen( Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION );

    /* Handle dark mode changes */
    handle_dark_mode_preference();

    /* Create the main window */
    appwin = new MainWindow( this, settings );

    /* List of directories and their rules */
    dirlist = new DirList();
    dirlist.load();

    if( create ) {
      create_data();
    }

    /* Save the results */
    dirlist.save();

    /* If we need to run rules, do it now */
    if( run_rules ) {
      dirlist.run( appwin );
    }

    /* Create the data controller */
    controller = new Controller( appwin, dirlist );

    /* Handle any changes to the position of the window */
    appwin.configure_event.connect(() => {
      int root_x, root_y;
      int size_w, size_h;
      appwin.get_position( out root_x, out root_y );
      appwin.get_size( out size_w, out size_h );
      settings.set_int( "window-x", root_x );
      settings.set_int( "window-y", root_y );
      settings.set_int( "window-w", size_w );
      settings.set_int( "window-h", size_h );
      return( false );
    });

  }

  /* Handles any changes to the user dark mode preference */
  private void handle_dark_mode_preference() {

    // First we get the default instances for Granite.Settings and Gtk.Settings
    var granite_settings = Granite.Settings.get_default ();
    var gtk_settings = Gtk.Settings.get_default ();

    // Then, we check if the user's preference is for the dark style and set it if it is
    gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

    // Finally, we listen to changes in Granite.Settings and update our app if the user changes their preference
    granite_settings.notify["prefers-color-scheme"].connect (() => {
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
    });

  }

  /* Called if we have no files to open */
  protected override void activate() {
    hold();
    Gtk.main();
    release();
  }

  /* Parse the command-line arguments */
  private void parse_arguments( ref unowned string[] args ) {

    var context = new OptionContext( "- Actioneer Options" );
    var options = new OptionEntry[4];

    /* Create the command-line options */
    options[0] = {"version", 0, 0, OptionArg.NONE, ref show_version, _( "Display version number" ), null};
    options[1] = {"run", 'r', 0, OptionArg.NONE, ref run_rules, _( "Runs Actioneer rules" ), null};
    options[2] = {"create", 'c', 0, OptionArg.NONE, ref create, _( "Create rules in app" ), null};
    options[3] = {null};

    /* Parse the arguments */
    try {
      context.set_help_enabled( true );
      context.add_main_entries( options, null );
      context.parse( ref args );
    } catch( OptionError e ) {
      stdout.printf( _( "ERROR: %s\n" ), e.message );
      stdout.printf( _( "Run '%s --help' to see valid options\n" ), args[0] );
      Process.exit( 1 );
    }

    /* If the version was specified, output it and then exit */
    if( show_version ) {
      stdout.printf( version + "\n" );
      Process.exit( 0 );
    }

  }

  /* Main routine which gets everything started */
  public static int main( string[] args ) {

    var app = new Actioneer();
    app.parse_arguments( ref args );

    return( app.run( args ) );

  }

}

