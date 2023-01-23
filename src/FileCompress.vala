public class FileCompress {

  public const string xml_node = "file-compress";

  public ZlibCompressorFormat type;
  public int level;

  public FileCompress() {
    type  = ZlibCompressorFormat.GZIP;
    level = -1;
  }

  /* Copy constructor */
  public FileCompress.copy( FileCompress other ) {
    type  = other.type;
    level = other.level;
  }

  /*
   Sets the type based on the extension of the given pathname.  Returns true if
   the pathname is a supported compression format; otherwise, returns false.
  */
  public bool set_type_from_path( string pathname, out string new_path ) {
    if( pathname.has_suffix( ".gz" ) ) {
      type = ZlibCompressorFormat.GZIP;
    } else if( pathname.has_suffix( ".raw" ) ) {
      type = ZlibCompressorFormat.RAW;
    } else if( pathname.has_suffix( ".zlib" ) ) {
      type = ZlibCompressorFormat.ZLIB;
    } else {
      return( false );
    }
    var parts = pathname.split( "." );
    new_path = string.joinv( ".", parts[0:parts.length - 1] );
    return( true );
  }

  /* Returns the extension to use for the compressed file */
  public string extension() {
    switch( type ) {
      case ZlibCompressorFormat.GZIP :  return( ".gz" );
      case ZlibCompressorFormat.RAW  :  return( ".raw" );
      case ZlibCompressorFormat.ZLIB :  return( ".zlib" );
      default                        :  assert_not_reached();
    }
  }

  public bool convert( File src, File dst, Converter converter ) throws Error {

    var src_stream  = src.read();
    var dst_stream  = dst.replace( null, false, 0 );
    var conv_stream = new ConverterOutputStream( dst_stream, converter );

    conv_stream.splice( src_stream, 0 );

    return( true );

  }

  /* Perform the compression */
  public bool compress( File src, File dst ) throws Error {
    return( convert( src, dst, new ZlibCompressor( type, level ) ) );
  }

  /* Perform the decompression */
  public bool decompress( File src, File dst ) throws Error {
    return( convert( src, dst, new ZlibDecompressor( type ) ) );
  }

  public Xml.Node* save() {

    Xml.Node* node = new Xml.Node( null, xml_node );

    node->set_prop( "type",  type.to_string() );
    node->set_prop( "level", level.to_string() );

    return( node );

  }

  public void load( Xml.Node* node ) {

    var t = node->get_prop( "type" );
    if( t != null ) {
      var gzip = ZlibCompressorFormat.GZIP;
      var raw  = ZlibCompressorFormat.RAW;
      var zlib = ZlibCompressorFormat.ZLIB;
      if( t == gzip.to_string() ) {
        type = gzip;
      } else if( t == raw.to_string() ) {
        type = raw;
      } else if( t == zlib.to_string() ) {
        type = zlib;
      }
    }

    var l = node->get_prop( "level" );
    if( l != null ) {
      level = int.parse( l );
    }

  }

}
