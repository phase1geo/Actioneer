using Gtk;

public class CondBase : Box {

  protected ActionConditionType _type;

  /* Default constructor */
  public CondBase( ActionConditionType type ) {
    Object( orientation: Orientation.HORIZONTAL, spacing: 10 );
    _type = type;
  }

  public virtual void set_data( ActionCondition data ) {
    assert( false );
  }

  public virtual ActionCondition get_data() {
    assert( false );
    return( new ActionCondition() );
  }

}
