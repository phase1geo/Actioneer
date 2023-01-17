using Gtk;

public class CondTextBox : CondBase {

  private TextOptMenu _menu;
  private Entry       _entry;
  private Revealer    _reveal;

  /* Default constructor */
  public CondTextBox( ActionConditionType type ) {

    base( type );

    _menu  = new TextOptMenu();
    _menu.activated.connect( menu_activated );

    _entry = new Entry();
    _entry.hexpand     = true;
    _entry.hexpand_set = true;

    _reveal = new Revealer();
    _reveal.transition_duration = 0;
    _reveal.add( _entry );

    pack_start( _menu,   false, false, 0 );
    pack_start( _reveal, false, true,  0 );
    show_all();

    _menu.activated( 0 );

  }

  private void menu_activated( int index ) {
    var type = (TextMatchType)index;
    _reveal.reveal_child = type.requires_expected();
    _entry.grab_focus();
  }

  public override ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );

    data.text.match_type = (TextMatchType)_menu.get_current_item();
    data.text.text       = _entry.text;

    return( data );

  }

  public override void set_data( ActionCondition data ) {
    _menu.set_current_item( (int)data.text.match_type );
    _entry.text = data.text.text;
  }

}
