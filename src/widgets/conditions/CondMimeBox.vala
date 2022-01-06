using Gtk;

public class CondMimeBox : CondInterface, Box {

  /* Default constructor */
  public CondMimeBox() {

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
