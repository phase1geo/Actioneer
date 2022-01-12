using Gtk;

public class RuleForm : Box {

  private const string MATCH_ALL = _( "Match ALL Conditions" );
  private const string MATCH_ANY = _( "Match ANY Condition" );

  private Entry         _name_entry;
  private MatchOptMenu  _match_mb;
  private CondBoxList   _conditions;
  private ActionBoxList _actions;

  public signal void save_requested( DirAction rule );
  public signal void cancel_requested();

  /* Default constructor */
  public RuleForm() {

    Object( orientation: Orientation.VERTICAL, spacing: 10, margin: 10 );

    var name       = create_name_frame();
    var conditions = create_condition_frame();
    var actions    = create_action_frame();
    var bbox       = create_button_bar();

    pack_start( name,       false, true, 0 );
    pack_start( conditions, false, true, 0 );
    pack_start( actions,    false, true, 0 );
    pack_end(   bbox,       false, true, 0 );

    show_all();

  }

  private Frame create_name_frame() {

    var frame = new Frame( _( "Rule Name" ) );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_CARD );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_ROUNDED );

    _name_entry = new Entry();
    _name_entry.margin = 10;

    frame.add( _name_entry );

    return( frame );

  }

  private Frame create_condition_frame() {

    var frame = new Frame( _( "Conditions" ) );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_CARD );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_ROUNDED );

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

    var frame = new Frame( _( "Actions" ) );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_CARD );
    frame.get_style_context().add_class( Granite.STYLE_CLASS_ROUNDED );

    _actions = new ActionBoxList();
    _actions.margin = 10;

    frame.add( _actions );

    return( frame );

  }

  private Box create_button_bar() {

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

}
