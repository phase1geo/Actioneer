using Gdk;

public enum ResizeMethod {
  WIDTH,
  HEIGHT,
  CONSTANT,
  PERCENT,
  NUM;

  public string to_string() {
    switch( this ) {
      case WIDTH    :  return( "width" );
      case HEIGHT   :  return( "height" );
      case CONSTANT :  return( "constant" );
      case PERCENT  :  return( "percent" );
      default       :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case WIDTH    :  return( "With Width" );
      case HEIGHT   :  return( "With Height" );
      case CONSTANT :  return( "Specific Size" );
      case PERCENT  :  return( "By Percentage" );
      default       :  assert_not_reached();
    }
  }

  public static ResizeMethod parse( string val ) {
    switch( val ) {
      case "constant" :  return( CONSTANT );
      case "width"    :  return( WIDTH );
      case "height"   :  return( HEIGHT );
      case "percent"  :  return( PERCENT );
      default         :  assert_not_reached();
    }
  }

  public bool resize( string pathname, int width, int height, double percent ) {
    int w, h;
    var format = Pixbuf.get_file_info( pathname, out w, out h );
    var keep   = true;
    switch( this ) {
      case WIDTH    :  height = -1;   break;
      case HEIGHT   :  width  = -1;   break;
      case CONSTANT :  keep = false;  break;
      case PERCENT  :  width = (int)(w * percent);  height = (int)(h * percent); break;
      default       :  assert_not_reached();
    }
    var buf = new Pixbuf.from_file_at_scale( pathname, width, height, keep );
    return( buf.save( pathname, format.get_name() ) );
  }

}

public enum ImagerFormat {
  JPG,
  PNG,
  PDF,
  SVG,
  BMP,
  NUM;

  public string to_string() {
    switch( this ) {
      case JPG :  return( "jpg" );
      case PNG :  return( "png" );
      case PDF :  return( "pdf" );
      case SVG :  return( "svg" );
      case BMP :  return( "bmp" );
      default  :  assert_not_reached();
    }
  }

  public string label() {
    switch( this ) {
      case JPG :  return( _( "JPG" ) );
      case PNG :  return( _( "PNG" ) );
      case PDF :  return( _( "JDF" ) );
      case SVG :  return( _( "SVG" ) );
      case BMP :  return( _( "BMP" ) );
      default  :  assert_not_reached();
    }
  }

  public static ImagerFormat parse( string val ) {
    switch( val ) {
      case "jpg" :  return( JPG );
      case "png" :  return( PNG );
      case "pdf" :  return( PDF );
      case "svg" :  return( SVG );
      case "bmp" :  return( BMP );
      default    :  assert_not_reached();
    }
  }

  private string convert_pathname( string pathname, string extension ) {
    var parts = Utils.file_fullname( pathname ).split( "." );
    if( parts.length == 1 ) {
      return( parts[0] + "." + extension );
    } else {
      return( string.joinv( ".", parts[0:(parts.length-1)] ) + "." + extension );
    }
  }

  private bool convert_jpg( Pixbuf buf, string saveas ) {
    return( buf.save( saveas, "jpeg" ) );
  }

  private bool convert_png( Pixbuf buf, string saveas ) {
    return( buf.save( saveas, "png" ) );
  }

  private bool convert_pdf( Pixbuf buf, string saveas ) {
    return( false );
  }

  private bool convert_svg( Pixbuf buf, string saveas ) {
    return( false );
  }

  private bool convert_bmp( Pixbuf buf, string saveas ) {
    return( buf.save( saveas, "bmp" ) );
  }

  public bool convert( ref string pathname ) {
    var buf    = new Pixbuf.from_file( pathname );
    var npath  = convert_pathname( pathname, to_string() );
    var retval = true;
    switch( this ) {
      case JPG :  retval = convert_jpg( buf, npath );  break;
      case PNG :  retval = convert_png( buf, npath );  break;
      case PDF :  retval = convert_pdf( buf, npath );  break;
      case SVG :  retval = convert_svg( buf, npath );  break;
      case BMP :  retval = convert_bmp( buf, npath );  break;
      default  :  assert_not_reached();
    }
    pathname = npath;
    return( retval );
  }

}

public class Imager {

  /* Default constructor */
  public Imager() {}

  public virtual void copy( Imager imager ) {}

  public virtual bool resize( string pathname ) {
    return( false );
  }

  public virtual bool convert( ref string pathname ) {
    return( false );
  }

  public virtual string xml_node() {
    return( "imager" );
  }

  public virtual void save( Xml.Node* node ) {}

  public virtual void load( Xml.Node* node ) {}

}

public class ImagerResizer : Imager {

  public ResizeMethod method  { get; set; default = ResizeMethod.WIDTH; }
  public int          width   { get; set; default = 0; }
  public int          height  { get; set; default = 0; }
  public double       percent { get; set; default = 0.0; }

  /* Default constructor */
  public ImagerResizer() {}

  /* Copy method */
  public ImagerResizer.copy( ImagerResizer other ) {
    method  = other.method;
    width   = other.width;
    height  = other.height;
    percent = other.percent;
  }

  public override bool resize( string pathname ) {
    return( method.resize( pathname, width, height, percent ) );
  }

  public override void save( Xml.Node* node ) {
    node->set_prop( "method", method.to_string() );
    switch( method ) {
      case ResizeMethod.WIDTH :
        node->set_prop( "width", width.to_string() );
        break;
      case ResizeMethod.HEIGHT :
        node->set_prop( "height", height.to_string() );
        break;
      case ResizeMethod.CONSTANT :
        node->set_prop( "width", width.to_string() );
        node->set_prop( "height", height.to_string() );
        break;
      case ResizeMethod.PERCENT :
        node->set_prop( "percent", percent.to_string() );
        break;
      default :  assert_not_reached();
    }
  }

  public override void load( Xml.Node* node ) {
    var m = node->get_prop( "method" );
    if( m != null ) {
      method = ResizeMethod.parse( m );
    }
    var w = node->get_prop( "width" );
    if( w != null ) {
      width = int.parse( w );
    }
    var h = node->get_prop( "height" );
    if( h != null ) {
      height = int.parse( h );
    }
    var p = node->get_prop( "percent" );
    if( p != null ) {
      percent = double.parse( p );
    }
  }

}

public class ImagerConverter : Imager {

  public ImagerFormat format { get; set; default = ImagerFormat.JPG; }

  /* Default constructor */
  public ImagerConverter() {}

  public ImagerConverter.copy( ImagerConverter other ) {
    format = other.format;
  }

  public override bool convert( ref string pathname ) {
    return( format.convert( ref pathname ) );
  }

  public override void save( Xml.Node* node ) {
    node->set_prop( "format", format.to_string() );
  }

  public override void load( Xml.Node* node ) {
    var f = node->get_prop( "format" );
    if( f != null ) {
      format = ImagerFormat.parse( f );
    }
  }

}

