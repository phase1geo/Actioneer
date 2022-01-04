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

public class DirActions {

  public static const string xml_node = "dir-actions";

  private string?          _dirname;
  private SList<DirAction> _actions;

  /* Default constructor */
  public DirActions() {
    _dirname = null;
    _actions = new SList<DirAction>();
  }

  /* Constructor */
  public DirActions.with_directory( string dirname ) {
    _dirname = dirname;
    _actions = new SList<DirAction>();
  }

  /* Returns the number of actions stored */
  public int num_actions() {
    return( (int)_actions.length() );
  }

  /* Returns the index at the given position */
  public DirAction get_action( int index ) {
    return( _actions.nth_data( index ) );
  }

  /* Adds a new directory action */
  public void add( DirAction action ) {
    _actions.append( action );
  }

  /* Removes the directory action from the stored list */
  public void remove( DirAction action ) {
    _actions.remove( action );
  }

  /* Runs the directory actions for this directory */
  public void run() {
    stdout.printf( "Running rules on directory %s\n", _dirname );
    _actions.foreach((action) => {
      action.run( _dirname );
    });
  }

  /* Saves the directory action as XML */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "dirname", _dirname );

    _actions.foreach((action) => {
      node->add_child( action.save() );
    });

    return( node );

  }

  /* Loads the directory action from the given XML node */
  public void load( Xml.Node* node ) {

    var n = node->get_prop( "dirname" );
    if( n != null ) {
      _dirname = n;
    }

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( (it->type == Xml.ElementType.ELEMENT_NODE) && (it->name == DirAction.xml_node) ) {
        var action = new DirAction();
        action.load( it );
        _actions.append( action );
      }
    }

  }

}
