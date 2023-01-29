using Gdk;

public class Utils {

  public static string tooltip_with_accel( string tooltip, string accel ) {
    string[] accels = {accel};
    return( Granite.markup_accel_tooltip( accels, tooltip ) );
  }

  /* Returns the full filename (without the leading directory path) of the given filename */
  public static string? file_fullname( string pathname ) {
    return( Filename.display_basename( pathname ) );
  }

  /* Returns the basename (minus the extension) of the given filename */
  public static string? file_name( string pathname ) {
    var parts = file_fullname( pathname ).split( "." );
    if( parts.length == 1 ) {
      return( parts[0] );
    } else {
      return( string.joinv( ".", parts[0:parts.length - 1] ) );
    }
  }

  /* Returns the extension of the given filename */
  public static string? file_extension( string pathname ) {
    var parts = file_fullname( pathname ).split( "." );
    if( parts.length == 1 ) {
      return( "" );
    } else {
      return( parts[parts.length - 1] );
    }
  }

  /* Returns the size (in bytes) of the given filename */
  public static int64 file_size( string pathname ) {
    var info = file_info( pathname );
    return( info.get_size() );
  }

  /* Returns the FileInfo associated with the given filename */
  public static FileInfo file_info( string pathname ) {
    var file = File.new_for_path( pathname );
    return( file.query_info( "time::*,standard::*,metadata::*,owner::*,xattr::*", 0 ) );
  }

  /* Displays file information to standard output */
  public static void show_file_info( string pathname ) {
    var file  = File.new_for_path( pathname );
    var info  = file.query_info( "*", 0 );
    var attrs = info.list_attributes( null );
    stdout.printf( "File Info for %s\n", pathname );
    for( int i=0; i<attrs.length; i++ ) {
      stdout.printf( "  %s (%s) = %s\n", attrs[i], info.get_attribute_type( attrs[i] ).to_string(), info.get_attribute_as_string( attrs[i] ) );
    }
  }

  /* Returns the creation date of the given filename */
  public static DateTime? file_create_date( string pathname ) {
     return( new DateTime.from_unix_local( (int64)file_info( pathname ).get_attribute_uint64( "time::created" ) ) );
  }

  /* Returns the modification date of the given filename */
  public static DateTime? file_modify_date( string pathname ) {
    return( file_info( pathname ).get_modification_date_time() );
  }

  public static string date_to_string( DateTime date, string pattern ) {
    return( date.format( pattern ) );
  }

  /* Returns the MIME type of the given filename */
  public static string? file_mime( string pathname ) {
    var content_type = file_info( pathname ).get_content_type();
    var mime_type    = ContentType.get_mime_type( content_type );
    return( mime_type );
  }

  /* Returns the file contents of the given file for searching */
  public static string? file_contents( string pathname ) {
    try {
      var contents = "";
      FileUtils.get_contents( pathname, out contents );
      return( contents );
    } catch( FileError e ) {
      return( null );
    }
  }

  /* Returns the URL that this file was downloaded from (if valid) */
  public static string? file_download_uri( string pathname ) {
    return( file_info( pathname ).get_attribute_string( "metadata::download-uri" ) );
  }

  /* Returns the owner of the given file */
  public static string? file_owner( string pathname ) {
    return( file_info( pathname ).get_attribute_string( "owner::user" ) );
  }

  /* Returns the Linux group of the given file */
  public static string? file_group( string pathname ) {
    return( file_info( pathname ).get_attribute_string( "owner::group" ) );
  }

  /* Sets the given file attribute to the specified string value */
  public static bool set_file_attribute( string pathname, string attr, string val ) {
    var file = File.new_for_path( pathname );
    try {
      return( file.set_attribute_string( attr, val, FileQueryInfoFlags.NONE ) );
    } catch( Error e ) {
      stdout.printf( "UNABLE TO SET ATTRIBUTE, pathname: %s, attr: %s, val: %s\n", pathname, attr, val );
      return( false );
    }
  }

  /* Returns the list of tags associated with the given file (xdg.tags) */
  public static string[]? file_tags( string pathname ) {
    return( file_info( pathname ).get_attribute_string( "xattr::xdg.tags" ).split( "," ) );
  }

  /* Adds the given tag to the specified file */
  public static bool file_add_tag( string pathname, string tag ) {
    string[] tags = {};
    var file = File.new_for_path( pathname );
    var tag_str = file_info( pathname ).get_attribute_string( "xattr::xdg.tags" );
    if( tag_str != null ) {
      tags = tag_str.split( "," );
    }
    for( int i=0; i<tags.length; i++ ) {
      if( tags[i] == tag ) {
        return( false );
      }
    }
    tags += tag;
    return( set_file_attribute( pathname, "xattr::xdg.tags", string.joinv( ",", tags ) ) );
  }

  /* Removes the given tag from the specified file, if it exists */
  public static bool file_remove_tag( string pathname, string tag ) {
    string[] tags = {};
    var file = File.new_for_path( pathname );
    var tag_str = file_info( pathname ).get_attribute_string( "xattr::xdg.tags" );
    if( tag_str != null ) {
      string[] new_tags = {};
      tags = tag_str.split( "," );
      for( int i=0; i<tags.length; i++ ) {
        if( tags[i] != tag ) {
          new_tags += tags[i];
        }
      }
      return( set_file_attribute( pathname, "xattr::xdg.tags", string.joinv( ",", new_tags ) ) );
    }
    return( false );
  }

  /* Clears all of the tags associated with the specified filename */
  public static bool file_clear_tags( string pathname ) {
    return( set_file_attribute( pathname, "xattr::xdg.tags", "" ) );
  }

  /* Returns the number of stars associated with the specified filename (or -1 if no stars exist) */
  public static int file_stars( string pathname ) {
    var stars = file_info( pathname ).get_attribute_string( "xattr::baloo.rating" );
    return( (stars != null) ? int.parse( stars ) : -1 );
  }

  /* Sets the number of stars associated with the filename */
  public static bool set_file_stars( string pathname, int stars ) {
    stdout.printf( "In set_file_stars, pathname: %s, stars: %d\n", pathname, stars );
    return( set_file_attribute( pathname, "xattr::baloo.rating", stars.to_string() ) );
  }

  /* Returns the file comment for the specified filename */
  public static string? file_comment( string pathname ) {
    return( file_info( pathname ).get_attribute_string( "xattr::xdg.comment" ) );
  }

  /* Sets the comment associated with the specified filename */
  public static bool set_file_comment( string pathname, string comment ) {
    stdout.printf( "In set_file_comment, pathname: %s, comment: %s\n", pathname, comment );
    return( set_file_attribute( pathname, "xattr::xdg.comment", comment ) );
  }

  public static int image_width( string pathname ) {
    int width, height;
    Pixbuf.get_file_info( pathname, out width, out height );
    return( width );
  }

  public static int image_height( string pathname ) {
    int width, height;
    Pixbuf.get_file_info( pathname, out width, out height );
    return( height );
  }

}
