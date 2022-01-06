using Gtk;

public class ActionRenameBox : ActionInterface, Box {

  /* Default constructor */
  public ActionRenameBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

    // FOOBAR

  }

  public FileAction get_data() {

    var data = new FileAction();

    // TBD

    return( data );

  }

  public void set_data( FileAction data ) {

    // TBD

  }

}
