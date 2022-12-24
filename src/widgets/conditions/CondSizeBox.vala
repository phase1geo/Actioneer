using Gtk;

public class CondSizeBox : CondBase {

  private IntOptMenu  _menu;
  private Entry       _entry;
  private SizeOptMenu _size;

  /* Default constructor */
  public CondSizeBox( ActionConditionType type ) {

    base( type );

    _menu = new IntOptMenu();
    _menu.activated.connect( menu_activated );

    _entry = new Entry();
    _entry.input_purpose = InputPurpose.DIGITS;
    _entry.text = "1";
    _entry.grab_focus();

    _size = new SizeOptMenu();

    pack_start( _menu,  false, false, 0 );
    pack_start( _entry, false, false, 0 );
    pack_start( _size,  false, false, 0 );
    show_all();

  }

  private void menu_activated( int index ) {
    _entry.grab_focus();
  }

  public override ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );
    var type = (SizeMatchType)_menu.get_current_item();
    var size = (SizeType)_size.get_current_item();

    data.size.match_type = type;
    data.size.num        = int64.parse( _entry.text );
    data.size.size       = size;

    return( data );

  }

  public override void set_data( ActionCondition data ) {

    _menu.set_current_item( (int)data.size.match_type );
    _entry.text = data.size.num.to_string();
    _size.set_current_item( (int)data.size.size );

  }

}
