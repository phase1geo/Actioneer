using Gtk;

public class RuleForm : Box {

  private const string MATCH_ALL = _( "Match ALL Conditions" );
  private const string MATCH_ANY = _( "Match ANY Condition" );

  private Entry         _name_entry;
  private MatchOptMenu  _match_mb;
  private CondBoxList   _conditions;
  private ActionBoxList _actions;
  private MainWindow    _win;

  public signal void save_requested( DirAction rule );
  public signal void cancel_requested();

  /* Default constructor */
  public RuleForm( MainWindow win ) {

    Object( orientation: Orientation.VERTICAL, spacing: 10, margin: 10 );

    _win = win;

    var name       = create_name_frame();
    var conditions = create_condition_frame();
    var actions    = create_action_frame();
    var bbox       = create_button_bar();

    var mid_box = new Box( Orientation.VERTICAL, 10 );
    mid_box.pack_start( conditions, false, true, 0 );
    mid_box.pack_start( actions,    false, true, 0 );

    var sw = new ScrolledWindow( null, null );
    sw.set_policy( PolicyType.NEVER, PolicyType.AUTOMATIC );
    sw.add( mid_box );

    pack_start( name, false, true, 0 );
    pack_start( sw,   true,  true, 0 );
    pack_end(   bbox, false, true, 0 );

    show_all();

  }

  private Frame create_frame( string name ) {

    var frame = new Frame( "<b>" + name + "</b>" );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_CARD );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_ROUNDED );

    var label = (Label)frame.label_widget;
    label.use_markup = true;
    label.margin = 5;

    return( frame );

  }

  private Frame create_name_frame() {

    var frame = create_frame( _( "Rule Name" ) );

    _name_entry = new Entry();
    _name_entry.margin = 10;

    frame.add( _name_entry );

    return( frame );

  }

  private Frame create_condition_frame() {

    var frame = create_frame( _( "Conditions" ) );

    _match_mb = new MatchOptMenu();

    var match_box = new Box( Orientation.HORIZONTAL, 0 );
    match_box.pack_start( _match_mb, false, false, 0 );

    _conditions = new CondBoxList();

    var box = new Box( Orientation.VERTICAL, 10 );
    box.margin = 10;
    box.pack_start( match_box,   false, true, 0 );
    box.pack_start( _conditions, false, true, 0 );

    frame.add( box );

    return( frame );

  }

  private Frame create_action_frame() {

    var frame = create_frame( _( "Actions" ) );

    _actions = new ActionBoxList();
    _actions.margin = 10;

    frame.add( _actions );

    return( frame );

  }

  private Box create_button_bar() {

    var test_btn = new Button.with_label( _( "Test" ) );
    test_btn.clicked.connect(() => {
      test_rule();
    });

    var save_btn = new Button.with_label( _( "Save Changes" ) );
    save_btn.get_style_context().add_class( "suggested-action" );
    save_btn.clicked.connect(() => {
      save_requested( create_rule() );
    });

    var cancel_btn = new Button.with_label( _( "Cancel" ) );
    cancel_btn.clicked.connect(() => {
      cancel_requested();
    });

    var box = new Box( Orientation.HORIZONTAL, 10 );
    box.pack_start( test_btn, false, false, 0 );
    box.pack_end( save_btn,   false, false, 0 );
    box.pack_end( cancel_btn, false, false, 0 );

    return( box );

  }

  /* Called to initialize the form with the information from the specified DirAction structure */
  public void initialize( DirAction rule ) {

    _name_entry.text = rule.name;
    _match_mb.set_current_item( rule.match_all ? (int)MatchType.ALL : (int)MatchType.ANY );

    _conditions.clear();
    _conditions.set_data( rule );

    _actions.clear();
    _actions.set_data( rule );

  }

  /* Called to create a DirAction rule that will be saved */
  private DirAction create_rule() {

    var rule = new DirAction.with_name( _name_entry.text );

    rule.match_all = (_match_mb.get_current_item() == MatchType.ALL);

    _conditions.get_data( rule );
    _actions.get_data( rule );

    return( rule );

  }

  private void test_rule() {

    /* Get file from user */
    var dialog = new FileChooserNative( _( "Choose File" ), _win, FileChooserAction.OPEN,
                                        _( "Choose" ), _( "Cancel" ) );

    if( dialog.run() == ResponseType.ACCEPT ) {
      var rule   = create_rule();
      var result = rule.test( dialog.get_filename() );
      stdout.printf( "Test result: %s\n", result.to_string() );
    }

  }

}
