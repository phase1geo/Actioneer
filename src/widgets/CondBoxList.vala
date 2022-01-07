using Gtk;

public class CondBoxList : BoxList {

  /* Default constructor */
  public CondBoxList() {
    base( _( "Add Condition" ) );
  }

  protected override OptMenu get_option_menu() {
    return( new CondOptMenu() );
  }

  protected override void insert_item( int index, Box box ) {
    Box item;
    var type = (ActionConditionType)index;
    switch( type ) {
      case NAME        :  item = new CondTextBox( type );  break;
      case EXTENSION   :  item = new CondTextBox( type );  break;
      case FULLNAME    :  item = new CondTextBox( type );  break;
      case CREATE_DATE :  item = new CondDateBox( type );  break;
      case MODIFY_DATE :  item = new CondDateBox( type );  break;
      case MIME        :  item = new CondMimeBox( type );  break;
      case CONTENT     :  item = new CondTextBox( type );  break;
      default          :  assert_not_reached();
    }
    box.pack_start( item, false, true, 0 );
  }

}
