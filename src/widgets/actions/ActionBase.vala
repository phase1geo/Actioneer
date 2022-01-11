using Gtk;

public class ActionBase : Box {

  protected FileActionType _type;

  /* Default constructor */
  public ActionBase( FileActionType type ) {
    Object( orientation: Orientation.HORIZONTAL, spacing: 10 );
    _type = type;
  }

  /* Takes the data from FileAction and creates the UI */
  public virtual void set_data( FileAction data ) {
    assert( false );
  }

  /* Stores the information from the UI as a FileAction */
  public virtual FileAction get_data() {
    assert( false );
    return( new FileAction() );
  }

}
