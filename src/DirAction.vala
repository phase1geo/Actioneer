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

public class DirAction {

  private string            _name;
  private ActionConditions  _conditions;
  private SList<FileAction> _actions;

  public bool   err    { get; set; default = false; }
  public string errmsg { get; set; default = ""; }

  /* Default constructor */
  public DirAction() {
    _name       = "";
    _conditions = new ActionConditions();
    _actions    = new SList<FileAction>();
  }

  /* Constructor */
  public DirAction.with_name( string name ) {
    _name       = name;
    _conditions = new ActionConditions();
    _actions    = new SList<FileAction>();
  }

  /* Runs the current action on the given directory */
  public void run( string dirname ) {

    try {

      string? name = null;
      var     dir  = Dir.open( dirname, 0 );

      /* Get the list of entries within the given directory */
      while( (name = dir.read_name()) != null ) {
        string path = Path.build_filename( dirname, name );
        if( _conditions.check( path ) ) {
          _actions.foreach((action) => {
            action.execute( path );
          });
        }
      }

    } catch( FileError e ) {
      err    = true;
      errmsg = e.message;
    }

  }

  /* Save the directory action to the given XML file */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, "diraction" );

    node->set_prop( "name", _name );

    node->add_child( _conditions.save() );

    _actions.foreach((action) => {
      node->add_child( action.save() );
    });

    return( node );

  }

  /* Loads a directory action from an XML node into this object */
  public void load( Xml.Node* node ) {

    var name = node->get_prop( "name" );
    if( name != null ) {
      _name = name;
    }

    for( Xml.Node* it=node->children; it!=null; it=it->next ) {
      if( it->type == Xml.ElementType.ELEMENT_NODE ) {
        switch( it->name ) {
          case "conditions" :
            _conditions.load( it );
            break;
          case "fileaction" :
            var action = new FileAction();
            action.load( it );
            _actions.append( action );
            break;
        }
      }
    }

  }

}
