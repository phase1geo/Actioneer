using Gtk;
using Gdk;

public class SearchPanel : Revealer {

  private MainWindow       _win;
  private SearchEntry      _entry;
  private Gtk.Menu         _history;
  private MenuButton       _history_btn;
  private SList<SearchCompletion> _completers;

  public signal void search_changed( string text, int curpos );
  public signal void search_closed( string text );

  /* Default constructor */
  public SearchPanel( MainWindow win ) {

    Object( reveal_child: false );

    _win     = win;
    _history = new Gtk.Menu();

    _entry = new SearchEntry();
    _entry.completion = new EntryCompletion();
    _entry.completion.set_text_column( 0 );
    _entry.completion.popup_completion = true;
    _entry.completion.popup_single_match = true;
    _entry.completion.minimum_key_length = 1;
    _entry.completion.set_match_func((c, k, it) => {
      return( true );
    });
    _entry.completion.match_selected.connect( completion_match_selected );

    _entry.search_changed.connect(() => {
      search_changed( _entry.text, _entry.cursor_position );
    });
    _entry.key_press_event.connect((e) => {
      switch( e.keyval ) {
        case Key.Escape    :  end_search();               break;
        case Key.Tab       :  insert_first_match();       break;
        case Key.parenleft :  insert_completion_paren();  break;
      }
      return( false );
    });

    var info_btn = new MenuButton();
    info_btn.image = new Image.from_icon_name( "dialog-question-symbolic", IconSize.SMALL_TOOLBAR );
    info_btn.relief = ReliefStyle.NONE;
    info_btn.set_tooltip_text( _( "Advanced Search Help" ) );
    info_btn.popover = new Popover( info_btn );
    info_btn.popover.border_width = 10;

    var info = new Label(
      _( "<b><u>Advanced search syntax:</u></b>\n\n" ) +
      _( "- All searching is case-insensitive\n" ) +
      _( "- Use <b><tt>:</tt></b> within a search term to specify a condition/action label (left) and an associated value (right)\n" ) +
      _( "- Add double-quotes (<b><tt>\"</tt></b>) around search terms containing spaces\n" ) +
      _( "- Add parenthesis around search terms to group them into a single search term\n" ) +
      _( "- Use <b><tt>&amp;</tt></b> between search terms to require both to be true\n" ) +
      _( "- Use <b><tt>|</tt></b> between search terms to require one or both to be true\n" ) +
      _( "- Use <b><tt>!</tt></b> before a search term to require the term to be false\n" ) +
      _( "- Whitespace is ignored unless used within double-quotes\n\n" ) +
      _( "<b><u>Examples:</u></b>\n\n" ) +
      _( "- Search for any rules that include \"Example Rule\" in their name\n" ) +
      _( "    <tt>\"Example Rule\"</tt>\n" ) +
      _( "- Searches any rules containing the Upload file action using a server called \"Test Server\":\n" ) +
      _( "    <tt>Upload:\"Test Server\"</tt>\n" ) +
      _( "- Search for any rules with Example and contains either an Extension condition of jpg or jpeg:\n" ) +
      _( "    <tt>Example &amp; (Extension:jpg | Extension:jpeg)</tt>\n" )
    );
    info.use_markup = true;
    info.wrap = true;
    info.wrap_mode = Pango.WrapMode.WORD;
    info.max_width_chars = 80;
    info.show_all();
    info_btn.popover.add( info );

    _history_btn = new MenuButton();
    _history_btn.image = new Image.from_icon_name( "go-down-symbolic", IconSize.SMALL_TOOLBAR );
    _history_btn.popup = _history;
    _history_btn.set_tooltip_text( _( "Search History" ) );

    var box = new Box( Orientation.HORIZONTAL, 10 );
    box.border_width = 10;
    box.pack_start( _entry,       true,  true,  0 );
    box.pack_end(   _history_btn, false, false, 0 );
    box.pack_end(   info_btn,     false, false, 0 );
    box.show_all();

    add( box );

  }

  /* Adds the given strings to the search history menu */
  public void set_search_history( SearchHistory history ) {

    /* Clear the history menu */
    _history.get_children().foreach((item) => {
      _history.remove( item );
    });

    /* Populate the history menu */
    for( int i=0; i<history.size(); i++ ) {
      var text = history.get_item( i );
      var item = new Gtk.MenuItem.with_label( text );
      item.activate.connect(() => {
        _entry.text = text;
      });
      _history.add( item );
    }
    _history.show_all();

    /* If we have no history to show, grey out the history button */
    _history_btn.set_sensitive( history.size() > 0 );

  }

  /* Called when this widget is requested by the user to begin a search */
  public void start_search() {

    _entry.text = "";
    _entry.grab_focus();
    reveal_child = true;

  }

  /* Called when the user requests to end searching */
  public void end_search() {

    reveal_child = false;
    search_closed( _entry.text );

  }

  /* Displays the available completers */
  public void set_completers( SList<SearchCompletion> completers ) {

    var store = new Gtk.ListStore( 2, typeof(string), typeof(int) );
    var index = 0;

    _completers = new SList<SearchCompletion>();

    completers.foreach((completer) => {
      TreeIter it;
      store.append( out it );
      store.set( it, 0, completer.get_label(), 1, index++ );
      _completers.append( completer );
    });

    _entry.completion.set_model( store );

  }

  private bool completion_match_selected( Gtk.TreeModel model, Gtk.TreeIter it ) {

    int index = -1;

    // Get the index of the item into the _completers list
    model.get( it, 1, &index );

    // Perform the text substitution
    if( index != -1 ) {
      var completer = _completers.nth_data( index );
      _entry.text = completer.get_replacement_string( _entry.text );
      _entry.set_position( completer.get_epos() );
    }

    return( true );

  }

  private void insert_first_match() {
    TreeIter iter = {};
    var model = _entry.completion.get_model();
    if( (model != null) && model.get_iter_first( out iter ) ) {
      completion_match_selected( model, iter );
    }
  }

  private void insert_completion_paren() {
    _entry.insert_at_cursor( ")" );
    _entry.set_position( _entry.get_position() - 1 );
  }

}
