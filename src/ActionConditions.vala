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

public class ActionConditions {

  public static const string xml_node = "conditions";

  private bool                   _match_all;
  private SList<ActionCondition> _conditions;

  /* Default constructor */
  public ActionConditions() {
    _match_all = true;
    _conditions = new SList<ActionCondition>();
  }

  public int num_conditions() {
    return( (int)_conditions.length() );
  }

  public void add_condition( ActionCondition condition ) {
    _conditions.append( condition );
  }

  public void remove_condition( ActionCondition condition ) {
    _conditions.remove( condition );
  }

  public ActionCondition get_condition( int index ) {
    return( _conditions.nth_data( index ) );
  }

  /* Returns true if the pathname passes all conditions */
  public bool check( string path ) {

    bool pass;

    if( _match_all ) {
      pass = true;
      _conditions.foreach((condition) => {
        pass &= condition.check( path );
      });
    } else {
      pass = false;
      _conditions.foreach((condition) => {
        pass |= condition.check( path );
      });
    }

    return( pass );

  }

  /* Saves the current condition in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, "conditions" );

    node->set_prop( "matchall", _match_all.to_string() );

    _conditions.foreach((condition) => {
      node->add_child( condition.save() );
    });

    return( node );

  }

  /* Loads the given condition from XML format */
  public void load( Xml.Node* node ) {

    var match_all = node->get_prop( "matchall" );
    if( match_all != null ) {
      _match_all = bool.parse( match_all );
    }

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == ActionCondition.xml_node) ) {
        var condition = new ActionCondition();
        condition.load( it );
        _conditions.append( condition );
      }
    }

  }

}
