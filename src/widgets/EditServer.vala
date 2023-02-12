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

public class EditServer : Hdy.ApplicationWindow {

  public signal void completed( int index );

  /* Create the main window UI */
  public EditServer( MainWindow win, Server? server ) {

    title = (server == null) ? _( "Add Server" ) : _( "Edit Server" );
    destroy_with_parent = true;
    accept_focus = true;
    modal = true;
    resizable = false;
    transient_for = win;
    border_width = 10;

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
      del.get_style_context().add_class( "destructive-action" );
      del.clicked.connect(() => {
        Actioneer.servers.remove_server_by_name( server.name );
        Actioneer.servers.save();
        completed( -1 );
        close();
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
      new_server.test.begin((obj, res) => {
        if( new_server.test.end( res ) ) {
          if( server == null ) {
            Actioneer.servers.add_server( new_server );
          }
          Actioneer.servers.save();
          completed( Actioneer.servers.get_server_index( name_entry.text ) );
          close();
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
      completed( -1 );
      close();
    });
    bbar.pack_end( cancel, false, false, 0 );

    var box = new Box( Orientation.VERTICAL, 10 );
    box.border_width = 10;

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

    add( box );
    show_all();

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

}

