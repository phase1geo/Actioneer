using Gtk;

public class CondDateBox : CondInterface, Box {

  /* Default constructor */
  public CondDateBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

  }

  public ActionCondition get_data() {

    var data = new ActionCondition();

    // TBD

    return( data );

  }

  public void set_data( ActionCondition data ) {

    // TBD

  }

}
