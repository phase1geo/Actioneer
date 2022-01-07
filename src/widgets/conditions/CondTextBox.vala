using Gtk;

public class CondTextBox : CondInterface, Box {

  private TextOptMenu         _menu;
  private Entry               _entry;
  private ActionConditionType _type;

  /* Default constructor */
  public CondTextBox( ActionConditionType type ) {

    Object( orientation: Orientation.HORIZONTAL, spacing: 10 );

    _type  = type;
    _menu  = new TextOptMenu();
    _entry = new Entry();

    _entry.hexpand     = true;
    _entry.hexpand_set = true;

    pack_start( _menu,  false, false, 0 );
    pack_start( _entry, false, true,  0 );

    _menu.activated( 0 );

    show_all();

  }

  public ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );

    data.text.match_type = (TextMatchType)_menu.get_current_item();
    data.text.text       = _entry.text;

    return( data );

  }

  public void set_data( ActionCondition data ) {
    _menu.set_current_item( (int)data.text.match_type );
    _entry.text = data.text.text;
  }

}
