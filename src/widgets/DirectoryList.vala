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

public enum DragTypes {
  URI
}

public class DirectoryList : EnableList {

  public static const Gtk.TargetEntry[] DRAG_TARGETS = {
    {"text/uri-list", 0, DragTypes.URI},
  };

  /* Create the main window UI */
  public DirectoryList( MainWindow w ) {

    base( w );

    /* Set ourselves up to be a drag target */
    Gtk.drag_dest_set( this, DestDefaults.MOTION | DestDefaults.DROP, DRAG_TARGETS, Gdk.DragAction.COPY );
    drag_motion.connect( handle_drag_motion );
    drag_data_received.connect( handle_drag_data_received );

  }

  private bool handle_drag_motion( Gdk.DragContext ctx, int x, int y, uint t ) {
    return( true );
  }

  private void handle_drag_data_received( Gdk.DragContext ctx, int x, int y, Gtk.SelectionData data, uint info, uint t ) {
    if( info == DragTypes.URI ) {
      foreach (var uri in data.get_uris()) {
        var fname = Filename.from_uri( uri );
        if( added( fname ) ) {
          add_row( true, fname, true );
        }
      }
    }
    Gtk.drag_finish( ctx, true, false, t );
  }

  protected override Pango.EllipsizeMode ellipsize_mode() {
    return( Pango.EllipsizeMode.START );
  }

  protected override string title() {
    return( _( "Directories" ) );
  }

  protected override string add_tooltip() {
    return( Utils.tooltip_with_accel( _( "Add Directory" ), "<Control>o" ) );
  }

  protected override string remove_tooltip() {
    return( _( "Remove Selected Directory" ) );
  }

  public override string? get_label() {
    var dialog = new FileChooserNative( _( "Choose Directory" ), win, FileChooserAction.SELECT_FOLDER, _( "Choose" ), _( "Cancel" ) );
    if( dialog.run() == ResponseType.ACCEPT ) {
      return( dialog.get_filename() );
    }
    return( null );
  }

}

