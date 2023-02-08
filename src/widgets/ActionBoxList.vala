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

  protected override void add_row( int row_type, bool show_opt_menu ) {
    _actions.append( new ActionBase( (FileActionType)0 ) );
    base.add_row( row_type, show_opt_menu );
  }

  protected override bool group_supported() {
    return( false );
  }

  protected override void delete_row( int index ) {
    base.delete_row( index );
    _actions.remove( _actions.nth_data( index ) );
  }

  protected override void move_row( int from, int to ) {
    if( from == to ) return;
    var action = _actions.nth_data( from );
    _actions.remove( action );
    _actions.insert( action, to );
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
      case FileActionType.MOVE        :  item = new ActionFileBox( type );      break;
      case FileActionType.COPY        :  item = new ActionFileBox( type );      break;
      case FileActionType.RENAME      :  item = new ActionRenameBox( type );    break;
      case FileActionType.ALIAS       :  item = new ActionFileBox( type );      break;
      case FileActionType.COMPRESS    :  item = new ActionCompressBox( type );  break;
      case FileActionType.DECOMPRESS  :  item = new ActionEmptyBox( type );     break;
      case FileActionType.TRASH       :  item = new ActionEmptyBox( type );     break;
      case FileActionType.ADD_TAG     :  item = new ActionTextBox( type );      break;
      case FileActionType.REMOVE_TAG  :  item = new ActionTextBox( type );      break;
      case FileActionType.CLEAR_TAGS  :  item = new ActionEmptyBox( type );     break;
      case FileActionType.STARS       :  item = new ActionStarBox( type );      break;
      case FileActionType.COMMENT     :  item = new ActionTextBox( type );      break;
      case FileActionType.IMG_RESIZE  :  item = new ActionResizeBox( type );    break;
      case FileActionType.IMG_CONVERT :  item = new ActionConvertBox( type );   break;
      case FileActionType.NOTIFY      :  item = new ActionRenameBox( type );    break;
      case FileActionType.RUN_SCRIPT  :  item = new ActionTextBox( type );      break;
      case FileActionType.OPEN        :  item = new ActionOpenBox( type );      break;
      default                         :  assert_not_reached();
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
      add_row( (int)act.action_type, false );
      _actions.nth_data( _actions.length() - 1 ).set_data( act );
    }
  }

}
