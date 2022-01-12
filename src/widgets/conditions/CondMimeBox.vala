using Gtk;

public class CondMimeBox : CondBase {

  private TextOptMenu _text;
  private ComboBox    _cb;
  private bool        _allow_popup = false;

  /* Default constructor */
  public CondMimeBox( ActionConditionType type ) {

    base( type );

    var model  = new Gtk.ListStore( 1, typeof(string) );
    var filter = new Gtk.TreeModelFilter( model, null );
    filter.set_visible_func( filter_results );

    _text = new TextOptMenu();
    _cb   = new ComboBox.with_model_and_entry( filter );
    _cb.entry_text_column = 0;

    var entry = (Entry)_cb.get_child();
    entry.changed.connect(() => {
      filter.refilter();
      stdout.printf( "Calling popup!\n" );
      if( _allow_popup ) {
        _cb.popup();
      }
      _allow_popup = true;
    });

    populate_mime_model( model);

    pack_start( _text, false, false, 0 );
    pack_start( _cb,   false, true,  0 );

    show_all();

  }

  private bool filter_results( TreeModel model, TreeIter it ) {

    var text  = "";
    var entry = (Entry)_cb.get_child();

    model.get( it, 0, &text, -1 );

    return( (entry.text == "") || text.contains( entry.text ) );

  }

  private void populate_mime_model( Gtk.ListStore model ) {

    /* Get the list of MIME types available and sort them alphabetically */
    var mime_types = ContentType.list_registered();
    mime_types.sort( strcmp );

    /* Populate the model with the list of values */
    mime_types.foreach((item) => {
      TreeIter it;
      model.append( out it );
      model.set( it, 0, item, -1 );
    });

  }

  public override ActionCondition get_data() {

    var data  = new ActionCondition.with_type( _type );
    var entry = (Entry)_cb.get_child();

    data.text.match_type = (TextMatchType)_text.get_current_item();
    data.text.text       = entry.text;

    return( data );

  }

  public override void set_data( ActionCondition data ) {

    var entry = (Entry)_cb.get_child();

    _text.set_current_item( (int)data.text.match_type );
    entry.text = data.text.text;

  }

}
