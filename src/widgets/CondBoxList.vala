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

  protected override void insert_item( int index, Box box ) {
    CondBase item;
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
    _conditions.append( item );
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
      add_item( (int)cond.cond_type );
      _conditions.nth_data( _conditions.length() - 1 ).set_data( cond );
    }
  }

}
