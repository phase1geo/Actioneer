using Gtk;

public class CondTextBox : CondInterface, Box {

  private TextOptMenu _menu;
  private Entry       _entry;

  /* Default constructor */
  public CondTextBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

    _menu  = new TextOptMenu();
    _entry = new Entry();

    pack_start( _menu,  false, false, 0 );
    pack_start( _entry, false, true,  0 );

    _menu.activated( 0 );

    show_all();

  }

  public ActionCondition get_data() {

    var data = new ActionCondition();

    // TBD

    return( data );

  }

  public void set_data( ActionCondition data ) {

    _menu.set_current_item( (int)data.text.match_type );
    _entry.text = data.text.text;

  }

}
