using Gtk;

public class CondDateBox : CondInterface, Box {

  private DateOptMenu _menu;
  private Box         _dbox;

  /* Default constructor */
  public CondDateBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

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

    var picker = new Granite.Widgets.DatePicker();

    _dbox.pack_start( picker, false, true, 0 );

  }

  private void add_relative_menu() {

    var entry = new Entry();
    entry.input_purpose = InputPurpose.DIGITS;

    var amount = new TimeOptMenu();

    _dbox.pack_start( entry,  false, false, 0 );
    _dbox.pack_start( amount, false, false, 0 );

  }

  public ActionCondition get_data() {

    var type = (ActionConditionType)_menu.get_current_item();
    var data = new ActionCondition.with_type( type );

    // TBD

    return( data );

  }

  public void set_data( ActionCondition data ) {

    _menu.set_current_item( (int)data.cond_type );

  }

}
