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

public class DirectoryList : EnableList {

  /* Create the main window UI */
  public DirectoryList( MainWindow w ) {
    base( w );
  }

  protected override string title() {
    return( _( "Directories" ) );
  }

  protected override string add_tooltip() {
    return( _( "Add Directory" ) );
  }

  protected override string remove_tooltip() {
    return( _( "Remove Selected Directory" ) );
  }

  public override void action_add() {
    var dialog = new FileChooserNative( _( "Choose Directory" ), win, FileChooserAction.SELECT_FOLDER, _( "Choose" ), _( "Cancel" ) );
    if( dialog.run() == ResponseType.ACCEPT ) {
      added( view, model, dialog.get_filename() );
    }
  }

}

