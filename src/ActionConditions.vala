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

public enum ConditionMatchType {
  ALL,
  ANY,
  NONE,
  NUM;

  public string to_string() {
    switch( this ) {
      case ALL  :  return( "all" );
      case ANY  :  return( "any" );
      case NONE :  return( "none" );
      default   :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case ALL  :  return( _( "Match ALL of the following" ) );
      case ANY  :  return( _( "Match ANY of the following" ) );
      case NONE :  return( _( "Match NONE of the following" ) );
      default   :  assert_not_reached();
    }
  }

  public static ConditionMatchType parse( string val ) {
    switch( val ) {
      case "all"  :  return( ALL );
      case "any"  :  return( ANY );
      case "none" :  return( NONE );
      default     :  assert_not_reached();
    }
  }

}

public class ActionConditions {

  public static const string xml_node = "conditions";

  private SList<ActionCondition> _conditions;

  public ConditionMatchType match_type { get; set; default = ConditionMatchType.ALL; }

  /* Default constructor */
  public ActionConditions() {
    _conditions = new SList<ActionCondition>();
  }

  /* Copies the contents of the specified conditions instance to ourself */
  public void copy( ActionConditions other ) {
    match_type = other.match_type;
    _conditions = new SList<ActionCondition>();
    other._conditions.foreach((cond) => {
      _conditions.append( new ActionCondition.copy( cond ) ); 
    });
  }

  public int size() {
    return( (int)_conditions.length() );
  }

  public void add( ActionCondition condition ) {
    _conditions.append( condition );
  }

  public void remove( ActionCondition condition ) {
    _conditions.remove( condition );
  }

  public ActionCondition get_condition( int index ) {
    return( _conditions.nth_data( index ) );
  }

  /* Returns true if the pathname passes all conditions */
  public bool check( string path, Array<TestResult>? results = null ) {

    var pass = (match_type != ConditionMatchType.ANY);

    _conditions.foreach((condition) => {
      string? result = null;
      var passed = condition.check( path, ref result );
      switch( match_type ) {
        case ConditionMatchType.ALL  :  pass &=  passed;  break;
        case ConditionMatchType.ANY  :  pass |=  passed;  break;
        case ConditionMatchType.NONE :  pass &= !passed;  break;
      }
      if( results != null ) {
        results.append_val( new TestResult( passed, result ) );
      }
    });

    return( pass );

  }

  /* Saves the current condition in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, "conditions" );

    node->set_prop( "match-type", match_type.to_string() );

    _conditions.foreach((condition) => {
      node->add_child( condition.save() );
    });

    return( node );

  }

  /* Loads the given condition from XML format */
  public void load( Xml.Node* node ) {

    var mt = node->get_prop( "match-type" );
    if( mt != null ) {
      match_type = ConditionMatchType.parse( mt );
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
