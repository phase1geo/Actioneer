using Gtk;

public class CondDateBox : CondBase {

  private DateOptMenu                _menu;
  private Box                        _dbox;
  private Granite.Widgets.DatePicker _picker;
  private Entry                      _entry;
  private TimeOptMenu                _amount;
  private ActionConditionType        _type;

  /* Default constructor */
  public CondDateBox( ActionConditionType type ) {

    base( type );

    _menu = new DateOptMenu();
    _menu.activated.connect( menu_activated );

    _dbox = new Box( Orientation.HORIZONTAL, 0 );

    pack_start( _menu, false, false, 0 );
    pack_start( _dbox, false, true,  0 );

    menu_activated( 0 );

  }

  private void menu_activated( int index ) {

    var type = (DateMatchType)index;

    /* Clear the dbox */
    _dbox.get_children().foreach((item) => {
      _dbox.remove( item );
    });

    if( type.is_absolute() ) {
      add_absolute_menu();
    } else if( type.is_relative() ) {
      add_relative_menu();
    }

    show_all();

  }

  private void add_absolute_menu() {
    _picker = new Granite.Widgets.DatePicker();
    _dbox.pack_start( _picker, false, true, 0 );
  }

  private void add_relative_menu() {

    _entry = new Entry();
    _entry.input_purpose = InputPurpose.DIGITS;

    _amount = new TimeOptMenu();

    _dbox.pack_start( _entry,  false, false, 0 );
    _dbox.pack_start( _amount, false, false, 0 );

  }

  public override ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );
    var type = (DateMatchType)_menu.get_current_item();

    data.date.match_type = type;

    if( type.is_absolute() ) {
      data.date.exp = _picker.date;
    } else if( type.is_relative() ) {
      data.date.num = int.parse( _entry.text );
      data.date.time_type = (TimeType)_amount.get_current_item();
    }

    return( data );

  }

  public override void set_data( ActionCondition data ) {

    var type = data.date.match_type;

    _menu.set_current_item( (int)type );

    if( type.is_absolute() ) {
      _picker.date = data.date.exp;
    } else if( type.is_relative() ) {
      _entry.text = data.date.num.to_string();
      _amount.set_current_item( (int)data.date.time_type );
    }

  }

}
