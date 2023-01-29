using Gtk;

public class CondTagsBox : CondBase {

  private TagsOptMenu _menu;
  private Revealer    _reveal;
  private Entry       _entry;

  /* Default constructor */
  public CondTagsBox( ActionConditionType type ) {

    base( type );

    _menu  = new TagsOptMenu();
    _menu.activated.connect( menu_activated );

    _entry = new Entry();

    _entry.hexpand     = true;
    _entry.hexpand_set = true;

    _reveal = new Revealer();
    _reveal.add( _entry );

    pack_start( _menu,   false, false, 0 );
    pack_start( _reveal, false, true,  0 );
    show_all();

    _menu.activated( 0 );

  }

  private void menu_activated( int index ) {
    var match_type = (TagsMatchType)index;
    switch( match_type ) {
      case TagsMatchType.CONTAINS     :
      case TagsMatchType.CONTAINS_NOT :
        _reveal.reveal_child = true;
        _entry.grab_focus();
        break;
      default :
        _reveal.reveal_child = false;
        break;
    }
  }

  public override ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );

    data.tags.match_type = (TagsMatchType)_menu.get_current_item();
    data.tags.text       = _entry.text;

    return( data );

  }

  public override void set_data( ActionCondition data ) {
    _menu.set_current_item( (int)data.tags.match_type );
    _entry.text = data.tags.text;
  }

}
