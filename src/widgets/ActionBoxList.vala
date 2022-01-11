using Gtk;

public class ActionBoxList : BoxList {

  private List<ActionBase> _actions;

  /* Default constructor */
  public ActionBoxList() {
    base( _( "Add Action" ) );
  }

  protected override OptMenu get_option_menu() {
    return( new ActionOptMenu() );
  }

  protected override void insert_item( int index, Box box ) {
    ActionBase item;
    var type = (FileActionType)index;
    switch( type ) {
      case MOVE        :  item = new ActionFileBox( type );    break;
      case COPY        :  item = new ActionFileBox( type );    break;
      case RENAME      :  item = new ActionRenameBox( type );  break;
      default          :  assert_not_reached();
    }
    _actions.append( item );
    box.pack_start( (Box)item, true, true, 0 );
  }

  public override void get_data( DirAction action ) {
    _actions.foreach((act) => {
      action.add_action( act.get_data() );
    });
  }

  public override void set_data( DirAction action ) {
    for( int i=0; i<action.num_actions(); i++ ) {
      var act = action.get_action( i );
      add_item( (int)act.action_type );
      _actions.nth_data( _actions.length() - 1 ).set_data( act );
    }
  }

}
