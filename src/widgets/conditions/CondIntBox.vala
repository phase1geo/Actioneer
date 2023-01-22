using Gtk;

public class CondIntBox : CondBase {

  private IntOptMenu _menu;
  private Entry      _entry;

  /* Default constructor */
  public CondIntBox( ActionConditionType type ) {

    base( type );

    _menu = new IntOptMenu();
    _menu.activated.connect( menu_activated );

    _entry = new Entry();
    _entry.input_purpose = InputPurpose.DIGITS;
    _entry.text = "1";
    _entry.grab_focus();

    pack_start( _menu,  false, false, 0 );
    pack_start( _entry, false, false, 0 );
    show_all();

  }

  private void menu_activated( int index ) {
    _entry.grab_focus();
  }

  public override ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );
    var type = (IntMatchType)_menu.get_current_item();

    data.num.match_type = type;
    data.num.num        = int.parse( _entry.text );

    return( data );

  }

  public override void set_data( ActionCondition data ) {

    _menu.set_current_item( (int)data.num.match_type );
    _entry.text = data.num.num.to_string();

  }

}
