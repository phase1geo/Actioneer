using Gtk;

public class CondGroupBox : CondBase {

  private MatchOptMenu _mb;
  private CondBoxList  _group;

  /* Default constructor */
  public CondGroupBox( ActionConditionType type ) {

    base( type );

    _mb = new MatchOptMenu();

    var tbox = new Box( Orientation.HORIZONTAL, 0 );
    tbox.pack_start( _mb, false, false, 0 );

    _group = new CondBoxList();

    var box = new Box( Orientation.VERTICAL, 10 );
    box.margin = 10;
    box.pack_start( tbox,   false, true, 0 );
    box.pack_start( _group, false, true, 0 );

    var frame = new Frame( null );
    frame.add( box );

    pack_start( frame, true, true, 0 );

    show_all();

  }

  public override ActionCondition get_data() {

    var dir_action = new DirAction();
    var data       = new ActionCondition.with_type( _type );

    _group.get_data( dir_action );

    data.group.copy( dir_action.conditions );
    data.group.match_type = (ConditionMatchType)_mb.get_current_item();

    return( data );

  }

  public override void set_data( ActionCondition data ) {

    var dir_action = new DirAction();

    dir_action.conditions.copy( data.group );

    _mb.set_current_item( (int)data.group.match_type );
    _group.set_data( dir_action );

  }

}
