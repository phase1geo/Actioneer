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
  URI,
  SIZE,
  OWNER,
  GROUP,
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
      case URI         :  return( "uri" );
      case SIZE        :  return( "size" );
      case OWNER       :  return( "owner" );
      case GROUP       :  return( "group" );
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
      case URI         :  return( _( "Download URL" ) );
      case SIZE        :  return( _( "File Size" ) );
      case OWNER       :  return( _( "Owner" ) );
      case GROUP       :  return( _( "Group" ) );
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
      case "uri"               :  return( URI );
      case "size"              :  return( SIZE );
      case "owner"             :  return( OWNER );
      case "group"             :  return( GROUP );
      default                  :  assert_not_reached();
    }
  }

  public bool is_text() {
    return( (this == NAME)      ||
            (this == EXTENSION) ||
            (this == FULLNAME)  ||
            (this == MIME)      ||
            (this == CONTENT)   ||
            (this == URI)       ||
            (this == OWNER)     ||
            (this == GROUP) );
  }

  public bool is_date() {
    return( (this == CREATE_DATE) || (this == MODIFY_DATE) );
  }

  public bool is_size() {
    return( this == SIZE );
  }

  /* Returns the current text value associated with the given filename */
  public string? text_from_pathname( string pathname ) {
    switch( this ) {
      case NAME      :  return( Utils.file_name( pathname ) );
      case EXTENSION :  return( Utils.file_extension( pathname ) );
      case FULLNAME  :  return( Utils.file_fullname( pathname ) );
      case MIME      :  return( Utils.file_mime( pathname ) );
      case CONTENT   :  return( Utils.file_contents( pathname ) );
      case URI       :  return( Utils.file_download_uri( pathname ) );
      case OWNER     :  return( Utils.file_owner( pathname ) );
      case GROUP     :  return( Utils.file_group( pathname ) );
      default        :  assert_not_reached();
    }
  }

  /* Returns the current date value associated with the given filename */
  public DateTime date_from_pathname( string pathname ) {
    switch( this ) {
      case CREATE_DATE :  return( Utils.file_create_date( pathname ) );
      case MODIFY_DATE :  return( Utils.file_modify_date( pathname ) );
      default          :  assert_not_reached();
    }
  }

  /* Returns the size (in bytes) of the given filename */
  public int64 size_from_pathname( string pathname ) {
    return( Utils.file_size( pathname ) );
  }

}

public class ActionCondition {

  public static const string xml_node = "condition";

  private ActionConditionType _type = ActionConditionType.NAME;
  private TextCondition?      _text = null;
  private DateCondition?      _date = null;
  private SizeCondition?      _size = null;

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
  public SizeCondition? size {
    get {
      return( _size );
    }
  }

  /* Default constructor */
  public ActionCondition() {}

  /* Constructor */
  public ActionCondition.with_type( ActionConditionType type ) {
    _type = type;
    _text = type.is_text() ? new TextCondition() : null;
    _date = type.is_date() ? new DateCondition() : null;
    _size = type.is_size() ? new SizeCondition() : null;
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
    if( other._size != null ) {
      _size = new SizeCondition.copy( other._size );
    }
  }

  /* Returns true if the given pathname passes this condition check */
  public bool check( string pathname, ref string? result ) {
    if( _type.is_text() ) {
      var val = _type.text_from_pathname( pathname );
      result = val;
      return( _text.check( val ) );
    } else if( _type.is_date() ) {
      var val = _type.date_from_pathname( pathname );
      result = val.to_string();
      return( _date.check( val ) );
    } else if( _type.is_size() ) {
      var val = _type.size_from_pathname( pathname );
      result = "%lld %s".printf( _size.size.get_size( val ), _size.size.label() );
      return( _size.check( val ) );
    }
    return( false );
  }

  /* Saves this condition in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type", _type.to_string() );

    if( _text != null ) {
      _text.save( node );
    } else if( _date != null ) {
      _date.save( node );
    } else if( _size != null ) {
      _size.save( node );
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

      if( _type.is_size() ) {
        _size = new SizeCondition();
        _size.load( node );
      }

    }

  }

}
