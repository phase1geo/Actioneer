using Gtk;

public class CondMimeBox : CondInterface, Box {

  private TextOptMenu _text;
  private MimeOptMenu _mime;

  /* Default constructor */
  public CondMimeBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

    _text = new TextOptMenu();
    _mime = new MimeOptMenu();

    pack_start( _text, false, false, 0 );
    pack_start( _mime, false, false, 0 );

    show_all();

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
