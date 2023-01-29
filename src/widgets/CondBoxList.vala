using Gtk;

public class CondBoxList : BoxList {

  private List<CondBase> _conditions;

  /* Default constructor */
  public CondBoxList() {
    base( _( "Add Condition" ) );
  }

  protected override OptMenu get_option_menu() {
    return( new CondOptMenu() );
  }

  protected override void add_row( int row_type, bool show_opt_menu ) {
    _conditions.append( new CondBase( (ActionConditionType)0 ) );
    base.add_row( row_type, show_opt_menu );
  }

  protected override void add_group() {
    _conditions.append( new CondBase( ActionConditionType.COND_GROUP ) );
    base.add_group();
  }

  protected override void delete_row( int index ) {
    base.delete_row( index );
    _conditions.remove( _conditions.nth_data( index ) );
  }

  protected override void move_row( int from, int to ) {
    if( from == to ) return;
    var condition = _conditions.nth_data( from );
    _conditions.remove( condition );
    _conditions.insert( condition, to );
  }

  protected override void clear() {
    base.clear();
    _conditions.foreach((cond) => {
      _conditions.remove( cond );
    });
  }

  protected override void set_row_content( int index, int row_type, Box box ) {
    CondBase item;
    var type = (ActionConditionType)row_type;
    switch( type ) {
      case ActionConditionType.NAME        :  item = new CondTextBox( type );   break;
      case ActionConditionType.EXTENSION   :  item = new CondTextBox( type );   break;
      case ActionConditionType.FULLNAME    :  item = new CondTextBox( type );   break;
      case ActionConditionType.CREATE_DATE :  item = new CondDateBox( type );   break;
      case ActionConditionType.MODIFY_DATE :  item = new CondDateBox( type );   break;
      case ActionConditionType.MIME        :  item = new CondMimeBox( type );   break;
      case ActionConditionType.CONTENT     :  item = new CondTextBox( type );   break;
      case ActionConditionType.URI         :  item = new CondTextBox( type );   break;
      case ActionConditionType.SIZE        :  item = new CondSizeBox( type );   break;
      case ActionConditionType.OWNER       :  item = new CondTextBox( type );   break;
      case ActionConditionType.GROUP       :  item = new CondTextBox( type );   break;
      case ActionConditionType.TAG         :  item = new CondTagsBox( type );   break;
      case ActionConditionType.STARS       :  item = new CondStarBox( type );   break;
      case ActionConditionType.COMMENT     :  item = new CondTextBox( type );   break;
      case ActionConditionType.IMG_WIDTH   :  item = new CondIntBox( type );    break;
      case ActionConditionType.IMG_HEIGHT  :  item = new CondIntBox( type );    break;
      case ActionConditionType.COND_GROUP  :  item = new CondGroupBox( type );  break;
      default                              :  assert_not_reached();
    }
    _conditions.nth( index ).data = item;
    box.pack_start( (Box)item, true, true, 0 );
  }

  public override void get_data( DirAction action ) {
    _conditions.foreach((cond) => {
      action.add_condition( cond.get_data() );
    });
  }

  public override void set_data( DirAction action ) {
    for( int i=0; i<action.num_conditions(); i++ ) {
      var cond = action.get_condition( i );
      if( cond.cond_type == ActionConditionType.COND_GROUP ) {
        add_group();
      } else {
        add_row( (int)cond.cond_type, false );
      }
      _conditions.nth_data( _conditions.length() - 1 ).set_data( cond );
    }
  }

}
