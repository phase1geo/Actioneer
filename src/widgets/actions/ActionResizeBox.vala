using Gtk;

public class ActionResizeBox : ActionBase {

  private ResizeOptMenu _mb;
  private Entry         _cwidth;
  private Entry         _cheight;
  private Entry         _width;
  private Entry         _height;
  private Entry         _percent;

  /* Default constructor */
  public ActionResizeBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );
    var stack = new Stack();

    _mb  = new ResizeOptMenu();
    _mb.activated.connect((index) => {
      var method = (ResizeMethod)index;
      stack.set_visible_child_name( method.to_string() );
    });

    add_to_stack( stack, create_constant(), ResizeMethod.CONSTANT );
    add_to_stack( stack, create_width(),    ResizeMethod.WIDTH );
    add_to_stack( stack, create_height(),   ResizeMethod.HEIGHT );
    add_to_stack( stack, create_percent(),  ResizeMethod.PERCENT );

    pack_start( label, false, false, 0 );
    pack_start( _mb,   false, false, 0 );
    pack_start( stack, false, true,  0 );

    _mb.set_current_item( (int)ResizeMethod.WIDTH );

  }

  private void add_to_stack( Stack stack, Box box, ResizeMethod method ) {
    stack.add_named( box, method.to_string() );
  }

  private Box create_constant() {

    var box = new Box( Orientation.HORIZONTAL, 10 );

    _cwidth = new Entry();
    _cwidth.placeholder_text = _( "Width in pixels" );

    var lbl = new Label( _( "x" ) );

    _cheight = new Entry();
    _cheight.placeholder_text = _( "Height in pixels" );

    box.pack_start( _cwidth,  false, false, 0 );
    box.pack_start( lbl,      false, false, 0 );
    box.pack_start( _cheight, false, false, 0 );

    return( box );

  }

  private Box create_width() {

    var box = new Box( Orientation.HORIZONTAL, 10 );

    _width = new Entry();
    _width.placeholder_text = _( "Width in pixels" );

    box.pack_start( _width, false, false, 0 );

    return( box );

  }

  private Box create_height() {

    var box = new Box( Orientation.HORIZONTAL, 10 );

    _height = new Entry();
    _height.placeholder_text = _( "Height in pixels" );

    box.pack_start( _height, false, false, 0 );

    return( box );

  }

  private Box create_percent() {

    var box = new Box( Orientation.HORIZONTAL, 10 );

    _percent = new Entry();
    _percent.placeholder_text = _( "Percent" );

    var lbl = new Label( "%" );

    box.pack_start( _percent, false, false, 0 );
    box.pack_start( lbl,      false, false, 0 );

    return( box );

  }

  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    var img  = (ImagerResizer)data.imager;
    img.method = (ResizeMethod)_mb.get_current_item();
    switch( img.method ) {
      case ResizeMethod.CONSTANT :
        img.width  = int.parse( _cwidth.text );
        img.height = int.parse( _cheight.text );
        break;
      case ResizeMethod.WIDTH :
        img.width  = int.parse( _width.text );
        img.height = -1;
        break;
      case ResizeMethod.HEIGHT :
        img.width  = -1;
        img.height = int.parse( _height.text );
        break;
      case ResizeMethod.PERCENT :
        img.percent = double.parse( _percent.text ) / 100;
        break;
    }
    return( data );
  }

  public override void set_data( FileAction data ) {
    var img = (ImagerResizer)data.imager;
    _mb.set_current_item( (int)img.method );
    switch( img.method ) {
      case ResizeMethod.CONSTANT :
        _cwidth.text  = img.width.to_string();
        _cheight.text = img.height.to_string();
        break;
      case ResizeMethod.WIDTH :
        _width.text = img.width.to_string();
        break;
      case ResizeMethod.HEIGHT :
        _height.text = img.height.to_string();
        break;
      case ResizeMethod.PERCENT :
        var percent = img.percent * 100;
        _percent.text = percent.to_string();
        break;
    }
  }

}
