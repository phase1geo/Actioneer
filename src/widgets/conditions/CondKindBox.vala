using Gtk;

public class CondKindBox : CondBase {

  private KindMatchOptMenu _match;
  private KindOptMenu      _kind;
  private Revealer         _reveal;

  /* Default constructor */
  public CondKindBox( ActionConditionType type ) {

    base( type );

    _reveal = new Revealer();
    _match  = new KindMatchOptMenu();
    _kind   = new KindOptMenu();
    _kind.activated.connect(() => {
      var current = (FileKind)_kind.get_current_item();
      _reveal.reveal_child = (current != FileKind.ANY);
    });

    _reveal.reveal_child = true;
    _reveal.add( _match );

    pack_start( _reveal, false, false, 0 );
    pack_start( _kind,   false, false, 0 );
    show_all();

    _kind.activated( 0 );

  }

  public override ActionCondition get_data() {

    var data = new ActionCondition.with_type( _type );

    data.kind.match_type = (KindMatchType)_match.get_current_item();
    data.kind.kind       = (FileKind)_kind.get_current_item();

    return( data );

  }

  public override void set_data( ActionCondition data ) {
    _match.set_current_item( (int)data.kind.match_type );
    _kind.set_current_item( (int)data.kind.kind );
  }

}
