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

public enum ConditionType {
  TEXT,
  DATE
}

public enum ActionConditionType {
  NAME,
  EXTENSION,
  FULLNAME,
  CREATE_DATE,
  MODIFY_DATE,
  MIME,
  CONTENT,
  NUM;

  public string to_string() {
    switch( this ) {
      case NAME        :  return( "name" );
      case EXTENSION   :  return( "extension" );
      case FULLNAME    :  return( "fullname" );
      case CREATE_DATE :  return( "creation-date" );
      case MODIFY_DATE :  return( "modification-date" );
      case MIME        :  return( "mime" );
      case CONTENT     :  return( "content" );
      default          :  assert_not_reached();
    }
  }

  public static ActionConditionType parse( string val ) {
    switch( val ) {
      case "name"              :  return( NAME );
      case "extension"         :  return( EXTENSION );
      case "fullname"          :  return( FULLNAME );
      case "creation-date"     :  return( CREATE_DATE );
      case "modification-date" :  return( MODIFY_DATE );
      case "mime"              :  return( MIME );
      case "content"           :  return( CONTENT );
      default                  :  assert_not_reached();
    }
  }

  public bool is_text() {
    return( (this == NAME) || (this == EXTENSION) || (this == FULLNAME) || (this == MIME) || (this == CONTENT) );
  }

  public bool is_date() {
    return( (this == CREATE_DATE) || (this == MODIFY_DATE) );
  }

  private string? get_fullname( string pathname ) {
    return( Filename.display_basename( pathname ) );
  }

  private string? get_name( string pathname ) {
    var parts = get_fullname( pathname ).split( "." );
    return( string.joinv( ".", parts[0:parts.length - 2] ) );
  }

  private string? get_extension( string pathname ) {
    var parts = get_fullname( pathname ).split( "." );
    return( parts[parts.length - 1] );
  }

  private FileInfo get_file_info( string pathname ) {
    var file = File.new_for_path( pathname );
    return( file.query_info( "time::*", 0 ) );
  }

  private DateTime? get_create_date( string pathname ) {
    return( null );
    // TBD
    // return( get_file_info( pathname ).get_creation_date_time() );
  }

  private DateTime? get_modify_date( string pathname ) {
    return( get_file_info( pathname ).get_modification_date_time() );
  }

  private string? get_mime( string pathname ) {
    // TBD
    return( "" );
  }

  private string? get_contents( string pathname ) {
    try {
      var contents = "";
      FileUtils.get_contents( pathname, out contents );
      return( contents );
    } catch( FileError e ) {
      return( null );
    }
  }

  public string text_from_pathname( string pathname ) {
    switch( this ) {
      case NAME      :  return( get_name( pathname ) );
      case EXTENSION :  return( get_extension( pathname ) );
      case FULLNAME  :  return( get_fullname( pathname ) );
      case MIME      :  return( get_mime( pathname ) );
      case CONTENT   :  return( get_contents( pathname ) );
      default        :  assert_not_reached();
    }
  }

  public DateTime date_from_pathname( string pathname ) {
    switch( this ) {
      case CREATE_DATE :  return( get_create_date( pathname ) );
      case MODIFY_DATE :  return( get_modify_date( pathname ) );
      default          :  assert_not_reached();
    }
  }

}

public class ActionCondition {

  public static const string xml_node = "condition";

  private ActionConditionType _type = ActionConditionType.NAME;
  private TextCondition?      _text = null;
  private DateCondition?      _date = null;

  public TextCondition? text {
    get {
      return( _text );
    }
  }
  public DateCondition? date {
    get {
      return( _date );
    }
  }

  /* Default constructor */
  public ActionCondition() {}

  /* Constructor */
  public ActionCondition.with_type( ActionConditionType type ) {
    _type = type;
    _text = type.is_text() ? new TextCondition() : null;
    _date = type.is_date() ? new DateCondition() : null;
  }

  /* Returns true if the given pathname passes this condition check */
  public bool check( string pathname ) {
    return( (_type.is_text() && _text.check( _type.text_from_pathname( pathname ) )) ||
            (_type.is_date() && _date.check( _type.date_from_pathname( pathname ) )) );
  }

  /* Saves this condition in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type", _type.to_string() );

    if( _text != null ) {
      _text.save( node );
    } else if( _date != null ) {
      _date.save( node );
    }

    return( node );

  }

  /* Loads this condition from XML format */
  public void load( Xml.Node* node ) {

    var t = node->get_prop( "type" );

    if( t != null ) {

      _type = ActionConditionType.parse( t );

      if( _type.is_text() ) {
        _text = new TextCondition();
        _text.load( node );
      }

      if( _type.is_date() ) {
        _date = new DateCondition();
        _date.load( node );
      }

    }

  }

}
