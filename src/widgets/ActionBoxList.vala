using Gtk;

public class ActionBoxList : BoxList {

  /* Default constructor */
  public ActionBoxList() {
    base( _( "Add Action" ) );
  }

  protected override OptMenu get_option_menu() {
    return( new ActionOptMenu() );
  }

  protected override void insert_item( int index, Box box ) {
    Box item;
    var type = (FileActionType)index;
    switch( type ) {
      case MOVE        :  item = new ActionFileBox();    break;
      case COPY        :  item = new ActionFileBox();    break;
      case RENAME      :  item = new ActionRenameBox();  break;
      default          :  assert_not_reached();
    }
    box.pack_start( item, false, true, 0 );
  }

}
