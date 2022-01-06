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

  public string label() {
    switch( this ) {
      case NAME        :  return( _( "Name" ) );
      case EXTENSION   :  return( _( "Extension" ) );
      case FULLNAME    :  return( _( "Full Name" ) );
      case CREATE_DATE :  return( _( "Creation Date" ) );
      case MODIFY_DATE :  return( _( "Modification Date" ) );
      case MIME        :  return( _( "MIME Type" ) );
      case CONTENT     :  return( _( "Content" ) );
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

  /* Returns the full filename (without the leading directory path) of the given filename */
  private string? get_fullname( string pathname ) {
    return( Filename.display_basename( pathname ) );
  }

  /* Returns the basename (minus the extension) of the given filename */
  private string? get_name( string pathname ) {
    var parts = get_fullname( pathname ).split( "." );
    return( string.joinv( ".", parts[0:parts.length - 2] ) );
  }

  /* Returns the extension of the given filename */
  private string? get_extension( string pathname ) {
    var parts = get_fullname( pathname ).split( "." );
    return( parts[parts.length - 1] );
  }

  /* Returns the FileInfo associated with the given filename */
  private FileInfo get_file_info( string pathname ) {
    var file = File.new_for_path( pathname );
    return( file.query_info( "time::*,standard::*", 0 ) );
  }

  /* Returns the creation date of the given filename */
  private DateTime? get_create_date( string pathname ) {
     return( new DateTime.from_unix_local( (int64)get_file_info( pathname ).get_attribute_uint64( "time::created" ) ) );
  }

  /* Returns the modification date of the given filename */
  private DateTime? get_modify_date( string pathname ) {
    return( get_file_info( pathname ).get_modification_date_time() );
  }

  /* Returns the MIME type of the given filename */
  private string? get_mime( string pathname ) {
    var content_type = get_file_info( pathname ).get_content_type();
    var mime_type    = ContentType.get_mime_type( content_type );
    return( mime_type );
  }

  /* Returns the file contents of the given file for searching */
  private string? get_contents( string pathname ) {
    try {
      var contents = "";
      FileUtils.get_contents( pathname, out contents );
      return( contents );
    } catch( FileError e ) {
      return( null );
    }
  }

  /* Returns the current text value associated with the given filename */
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

  /* Returns the current date value associated with the given filename */
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

  public ActionConditionType cond_type {
    get {
      return( _type );
    }
  }
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

  /* Copy constructor */
  public ActionCondition.copy( ActionCondition other ) {
    _type = other._type;
    if( other._text != null ) {
      _text = new TextCondition.copy( other._text );
    }
    if( other._date != null ) {
      _date = new DateCondition.copy( other._date );
    }
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
