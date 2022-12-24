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

  protected override void add_row( int row_type ) {
    _conditions.append( new CondBase( (ActionConditionType)0 ) );
    base.add_row( row_type );
  }

  protected override void delete_row( int index ) {
    base.delete_row( index );
    _conditions.remove( _conditions.nth_data( index ) );
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
      case NAME        :  item = new CondTextBox( type );  break;
      case EXTENSION   :  item = new CondTextBox( type );  break;
      case FULLNAME    :  item = new CondTextBox( type );  break;
      case CREATE_DATE :  item = new CondDateBox( type );  break;
      case MODIFY_DATE :  item = new CondDateBox( type );  break;
      case MIME        :  item = new CondMimeBox( type );  break;
      case CONTENT     :  item = new CondTextBox( type );  break;
      case SIZE        :  item = new CondSizeBox( type );  break;
      default          :  assert_not_reached();
    }
    _conditions.nth( index ).data = item;
    box.pack_start( (Box)item, false, true, 0 );
  }

  public override void get_data( DirAction action ) {
    _conditions.foreach((cond) => {
      action.add_condition( cond.get_data() );
    });
  }

  public override void set_data( DirAction action ) {
    for( int i=0; i<action.num_conditions(); i++ ) {
      var cond = action.get_condition( i );
      add_row( (int)cond.cond_type );
      _conditions.nth_data( _conditions.length() - 1 ).set_data( cond );
    }
  }

}
