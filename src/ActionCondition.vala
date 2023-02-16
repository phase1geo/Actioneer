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
  KIND,
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
  TAG,
  STARS,
  COMMENT,
  IMG_WIDTH,
  IMG_HEIGHT,
  COND_GROUP,
  NUM;

  public string to_string() {
    switch( this ) {
      case KIND        :  return( "kind" );
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
      case TAG         :  return( "tag" );
      case STARS       :  return( "stars" );
      case COMMENT     :  return( "comment" );
      case IMG_WIDTH   :  return( "img-width" );
      case IMG_HEIGHT  :  return( "img-height" );
      case COND_GROUP  :  return( "cond-group" );
      default          :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case KIND        :  return( _( "File Kind" ) );
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
      case TAG         :  return( _( "Tags" ) );
      case STARS       :  return( _( "Rating" ) );
      case COMMENT     :  return( _( "Comment" ) );
      case IMG_WIDTH   :  return( _( "Image Width" ) );
      case IMG_HEIGHT  :  return( _( "Image Height" ) );
      case COND_GROUP  :  return( _( "Condition Group" ) );
      default          :  assert_not_reached();
    }
  }

  public static ActionConditionType parse( string val, bool assert_if_not_found = true ) {
    switch( val ) {
      case "kind"              :  return( KIND );
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
      case "tag"               :  return( TAG );
      case "stars"             :  return( STARS );
      case "comment"           :  return( COMMENT );
      case "img-width"         :  return( IMG_WIDTH );
      case "img-height"        :  return( IMG_HEIGHT );
      case "cond-group"        :  return( COND_GROUP );
      default                  :
        if( assert_if_not_found ) {
          assert_not_reached();
        } else {
          return( NUM );
        }
        break;
    }
  }

  public bool is_kind() {
    return( this == KIND );
  }

  public bool is_text() {
    return( (this == NAME)      ||
            (this == EXTENSION) ||
            (this == FULLNAME)  ||
            (this == MIME)      ||
            (this == CONTENT)   ||
            (this == URI)       ||
            (this == OWNER)     ||
            (this == GROUP)     ||
            (this == COMMENT) );
  }

  public bool is_date() {
    return( (this == CREATE_DATE) || (this == MODIFY_DATE) );
  }

  public bool is_size() {
    return( this == SIZE );
  }

  public bool is_star() {
    return( this == STARS );
  }

  public bool is_tags() {
    return( this == TAG );
  }

  public bool is_int() {
    return( (this == STARS) || (this == IMG_WIDTH) || (this == IMG_HEIGHT) );
  }

  public bool is_cond_group() {
    return( this == COND_GROUP );
  }

  /* Returns the file type of the given pathname */
  public FileKind kind_from_pathname( string pathname ) {
    if( FileUtils.test( pathname, FileTest.IS_DIR ) ) {
      return( FileKind.FOLDER );
    } else if( FileUtils.test( pathname, FileTest.IS_SYMLINK ) ) {
      return( FileKind.ALIAS );
    } else if( FileUtils.test( pathname, FileTest.IS_REGULAR ) ) {
      var name = Utils.file_fullname( pathname );
      return( name.has_prefix( "." ) ? FileKind.HIDDEN : FileKind.FILE );
    } else {
      return( FileKind.ANY );
    }
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
      case COMMENT   :  return( Utils.file_comment( pathname ) );
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

  /* Returns the list of tags associated with the given filename */
  public string[]? tags_from_pathname( string pathname ) {
    return( Utils.file_tags( pathname ) );
  }

  /* Returns an integer value from the given pathname */
  public int int_from_pathname( string pathname ) {
    switch( this ) {
      case STARS      :  return( Utils.file_stars( pathname ) );
      case IMG_WIDTH  :  return( Utils.image_width( pathname ) );
      case IMG_HEIGHT :  return( Utils.image_height( pathname ) );
      default         :  assert_not_reached();
    }
  }

}

public class ActionCondition {

  public static const string xml_node = "condition";

  private ActionConditionType _type  = ActionConditionType.NAME;
  private KindCondition?      _kind  = null;
  private TextCondition?      _text  = null;
  private DateCondition?      _date  = null;
  private SizeCondition?      _size  = null;
  private TagsCondition?      _tags  = null;
  private IntCondition?       _num   = null;
  private ActionConditions?   _group = null;

  public ActionConditionType cond_type {
    get {
      return( _type );
    }
  }
  public KindCondition? kind {
    get {
      return( _kind );
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
  public TagsCondition? tags {
    get {
      return( _tags );
    }
  }
  public IntCondition? num {
    get {
      return( _num );
    }
  }
  public ActionConditions? group {
    get {
      return( _group );
    }
  }

  /* Default constructor */
  public ActionCondition() {}

  /* Constructor */
  public ActionCondition.with_type( ActionConditionType type ) {
    _type  = type;
    _kind  = type.is_kind() ? new KindCondition() : null;
    _text  = type.is_text() ? new TextCondition() : null;
    _date  = type.is_date() ? new DateCondition() : null;
    _size  = type.is_size() ? new SizeCondition() : null;
    _num   = type.is_int()  ? new IntCondition()  : null;
    _tags  = type.is_tags() ? new TagsCondition() : null;
    _group = type.is_cond_group() ? new ActionConditions() : null;
  }

  /* Copy constructor */
  public ActionCondition.copy( ActionCondition other ) {
    _type = other._type;
    if( other._kind != null ) {
      _kind = new KindCondition.copy( other._kind );
    }
    if( other._text != null ) {
      _text = new TextCondition.copy( other._text );
    }
    if( other._date != null ) {
      _date = new DateCondition.copy( other._date );
    }
    if( other._size != null ) {
      _size = new SizeCondition.copy( other._size );
    }
    if( other._num != null ) {
      _num = new IntCondition.copy( other._num );
    }
    if( other._tags != null ) {
      _tags = new TagsCondition.copy( other._tags );
    }
    if( other._group != null ) {
      _group = new ActionConditions();
      _group.copy( other._group );
    }
  }

  /* Returns true if the given pathname passes this condition check */
  public bool check( string pathname, ref string? result ) {
    if( _type.is_kind() ) {
      var val = _type.kind_from_pathname( pathname );
      result = val.to_string();
      return( _kind.check( val ) );
    } else if( _type.is_text() ) {
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
    } else if( _type.is_int() ) {
      var val = _type.int_from_pathname( pathname );
      result = "%d".printf( val );
      return( _num.check( val ) );
    } else if( _type.is_tags() ) {
      var val = _type.tags_from_pathname( pathname );
      result = string.joinv( ",", val );
      return( _tags.check( val ) );
    } else if( _type.is_cond_group() ) {
      var results = new Array<TestResult>();
      var retval  = _group.check( pathname, results );
      result = "TODO";
      return( retval );
    }
    return( false );
  }

  public bool matches( ActionConditionType? type, string value ) {
    if( _type.is_kind() ) {
      return( _kind.matches( value ) );
    } else if( _type.is_text() ) {
      return( _text.matches( value ) );
    } else if( _type.is_date() ) {
      return( _date.matches( value ) );
    } else if( _type.is_size() ) {
      return( _size.matches( value ) );
    } else if( _type.is_int() ) {
      return( _num.matches( value ) );
    } else if( _type.is_tags() ) {
      return( _tags.matches( value ) );
    } else if( _type.is_cond_group() ) {
      for( int i=0; i<_group.size(); i++ ) {
        var cond = _group.get_condition( i );
        if( (type == null) || (cond.cond_type == type) ) {
          return( cond.matches( type, value ) );
        }
      }
    }
    return( false );
  }

  /* Saves this condition in XML format */
  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type", _type.to_string() );

    if( _kind != null ) {
      _kind.save( node );
    } else if( _text != null ) {
      _text.save( node );
    } else if( _date != null ) {
      _date.save( node );
    } else if( _size != null ) {
      _size.save( node );
    } else if( _num != null ) {
      _num.save( node );
    } else if( _tags != null ) {
      _tags.save( node );
    } else if( _group != null ) {
      node->add_child( _group.save() );
    }

    return( node );

  }

  /* Loads this condition from XML format */
  public void load( Xml.Node* node ) {

    var t = node->get_prop( "type" );

    if( t != null ) {

      _type = ActionConditionType.parse( t );

      if( _type.is_kind() ) {
        _kind = new KindCondition();
        _kind.load( node );
      }

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

      if( _type.is_int() ) {
        _num = new IntCondition();
        _num.load( node );
      }

      if( _type.is_tags() ) {
        _tags = new TagsCondition();
        _tags.load( node );
      }

      if( _type.is_cond_group() ) {
        _group = new ActionConditions();
        _group.load( node );
      }

    }

  }

}
