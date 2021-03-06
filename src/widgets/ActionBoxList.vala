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

  protected override void add_row( int row_type ) {
    _actions.append( new ActionBase( (FileActionType)0 ) );
    base.add_row( row_type );
  }

  protected override void delete_row( int index ) {
    base.delete_row( index );
    _actions.remove( _actions.nth_data( index ) );
  }

  protected override void clear() {
    base.clear();
    _actions.foreach((action) => {
      _actions.remove( action );
    });
  }

  protected override void set_row_content( int index, int row_type, Box box ) {
    ActionBase item;
    var type = (FileActionType)row_type;
    switch( type ) {
      case MOVE        :  item = new ActionFileBox( type );    break;
      case COPY        :  item = new ActionFileBox( type );    break;
      case RENAME      :  item = new ActionRenameBox( type );  break;
      default          :  assert_not_reached();
    }
    _actions.nth( index ).data = item;
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
      add_row( (int)act.action_type );
      _actions.nth_data( _actions.length() - 1 ).set_data( act );
    }
  }

}
