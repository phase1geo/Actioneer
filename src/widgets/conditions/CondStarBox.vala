using Gtk;
using Gdk;

public class CondStarBox : CondBase {

  private StarOptMenu _menu;
  private Button      _stars[5];

  /* Default constructor */
  public CondStarBox( ActionConditionType type ) {

    base( type );

    _menu  = new StarOptMenu();
    _menu.activated.connect( menu_activated );

    var sbox = new Box( Orientation.HORIZONTAL, 0 );

    for( int i=0; i<5; i++ ) {
      var index = i;
      _stars[i] = new Button();
      _stars[i].relief = ReliefStyle.NONE;
      _stars[i].clicked.connect(() => {
        set_stars( (is_star_set( index ) && !is_star_set( index + 1 )) ? index : (index + 1) );
      });
      sbox.pack_start( _stars[i], false, false, 0 );
    }

    pack_start( _menu, false, false, 0 );
    pack_start( sbox,  false, true,  0 );
    show_all();

    /* Default to three stars */
    set_stars( 3 );
        
    /* Activate the first menu item */
    _menu.activated( 0 );

  }

  private void menu_activated( int index ) {
    _stars[0].grab_focus();
  }

  /* Sets the star buttons based on the given number */
  private void set_stars( int num ) {
    for( int i=0; i<5; i++ ) {
      if( i < num ) {
        _stars[i].image = new Image.from_icon_name( "starred", IconSize.SMALL_TOOLBAR );
      } else {
        _stars[i].image = new Image.from_icon_name( "non-starred", IconSize.SMALL_TOOLBAR );
      }
    }
  }

  /* Returns true if the given star is set */
  private bool is_star_set( int num ) {
    return( (num < 5) && ((_stars[num].image as Image).icon_name == "starred") );
  }

  /* Save the results off as TokenText */
  public override ActionCondition get_data() {
    var data  = new ActionCondition.with_type( _type );
    var stars = 0;
    for( int i=0; i<5; i++ ) {
      var img = (Image)_stars[i].image;
      stars += (img.icon_name == "starred") ? 2 : 0;
    }
    data.star.match_type = (StarMatchType)_menu.get_current_item();
    data.star.num        = stars;
    return( data );
  }

  /* Sets the stars based on the given FileAction value */
  public override void set_data( ActionCondition data ) {
    _menu.set_current_item( (int)data.star.match_type );
    set_stars( data.star.num / 2 );
  }

}
