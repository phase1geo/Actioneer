using Gtk;

public class CondGroupBox : CondBase {

  private CondBoxList _group;

  /* Default constructor */
  public CondGroupBox( ActionConditionType type ) {

    base( type );

    var mb = new MatchOptMenu();

    var tbox = new Box( Orientation.HORIZONTAL, 0 );
    tbox.pack_start( mb, false, false, 0 );

    _group = new CondBoxList();

    var box  = new Box( Orientation.VERTICAL, 0 );
    box.pack_start( tbox,   false, true, 0 );
    box.pack_start( _group, false, true, 0 );

    pack_start( box, false, true, 0 );

    stdout.printf( "In CondGroupBox\n" );

  }

  public override ActionCondition get_data() {

    var dir_action = new DirAction();
    var data       = new ActionCondition.with_type( _type );

    _group.get_data( dir_action );

    data.group.copy( dir_action.conditions );

    return( data );

  }

  public override void set_data( ActionCondition data ) {

    var dir_action = new DirAction();

    dir_action.conditions.copy( data.group );

    _group.set_data( dir_action );

  }

}
