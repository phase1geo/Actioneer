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

public class ActionOptMenu : OptMenu {

  /* Default constructor */
  public ActionOptMenu() {
    base();
  }

  protected override int num_items() {
    return( FileActionType.NUM );
  }

  protected override string get_item_label( int index ) {
    var type = (FileActionType)index;
    return( type.label() );
  }

  protected override bool get_item_separator( int index ) {
    var type = (FileActionType)index;
    return( type.add_separator_after() );
  }

}

