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
      case NAME        :  item = new CondTextBox();  break;
      case EXTENSION   :  item = new CondTextBox();  break;
      case FULLNAME    :  item = new CondTextBox();  break;
      case CREATE_DATE :  item = new CondDateBox();  break;
      case MODIFY_DATE :  item = new CondDateBox();  break;
      case MIME        :  item = new CondMimeBox();  break;
      case CONTENT     :  item = new CondTextBox();  break;
      default          :  assert_not_reached();
    }
    box.pack_start( item, false, true, 0 );
  }

}
