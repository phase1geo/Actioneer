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

public class CompFormatOptMenu : OptMenu {

  /* Default constructor */
  public CompFormatOptMenu() {
    base();
  }

  protected override int num_items() {
    return( 3 );
  }

  protected override string get_item_label( int index ) {
    switch( index ) {
      case 0  :  return( "GZIP" );
      case 1  :  return( "RAW" );
      case 2  :  return( "ZLIB" );
      default :  assert_not_reached();
    }
  }

  public void set_from_type( ZlibCompressorFormat type ) {
    switch( type ) {
      case ZlibCompressorFormat.GZIP :  set_current_item( 0 );  break;
      case ZlibCompressorFormat.RAW  :  set_current_item( 1 );  break;
      case ZlibCompressorFormat.ZLIB :  set_current_item( 2 );  break;
      default                        :  assert_not_reached();
    }
  }

  public ZlibCompressorFormat get_zlib_type() {
    switch( get_current_item() ) {
      case 0  :  return( ZlibCompressorFormat.GZIP );
      case 1  :  return( ZlibCompressorFormat.RAW );
      case 2  :  return( ZlibCompressorFormat.ZLIB );
      default :  assert_not_reached();
    }
  }

}

