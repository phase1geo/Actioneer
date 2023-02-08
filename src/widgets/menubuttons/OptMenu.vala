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

public class OptMenu : MenuButton {

  public signal void activated( int index );

  /* Create the main window UI */
  public OptMenu() {

    initialize();

    var menu = new Gtk.Menu();

    for( int i=0; i<num_items(); i++ ) {
      var lbl   = get_item_label( i );
      var sep   = get_item_separator( i );
      var item  = new Gtk.MenuItem.with_label( lbl );
      var index = i;
      item.activate.connect(() => {
        label = lbl;
        activated( index );
      });
      menu.add( item );
      if( sep ) {
        menu.add( new Gtk.SeparatorMenuItem() );
      }
    }

    menu.show_all();

    popup = menu;

    /* Initialize ourselves with the first item */
    if( num_items() > 0 ) {
      set_current_item( 0 );
    }

  }

  /* Allows the extended class to initialize itself, if needed */
  public virtual void initialize() {}

  /* Sets the current item to the given index */
  public void set_current_item( int index ) {
    int i = 0;
    popup.get_children().foreach((item) => {
      if( ((item as Gtk.SeparatorMenuItem) == null) && (index == i++) ) {
        item.activate();
      }
    });
  }

  /* Returns the current item index that is selected */
  public int get_current_item() {
    int index = -1;
    int i     = 0;
    popup.get_children().foreach((item) => {
      if( (item as Gtk.SeparatorMenuItem) == null ) {
        if( (item as Gtk.MenuItem).label == label ) {
          index = i;
        }
        i++;
      }
    });
    return( index );
  }

  protected virtual int num_items() {
    return( 0 );
  }

  protected virtual string get_item_label( int index ) {
    assert( false );
    return( "" );
  }

  protected virtual bool get_item_separator( int index ) {
    return( false );
  }

}

