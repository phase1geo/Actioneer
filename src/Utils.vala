public class Utils {

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
    return( file.query_info( "time::*,standard::*,metadata::*,owner::*", 0 ) );
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

}
