using Gtk;
using Gdk;

public class ActionStarBox : ActionBase {

  private Button _stars[5];

  /* Default constructor */
  public ActionStarBox( FileActionType type ) {

    base( type );

    if( type.pretext() != "" ) {
      var label = new Label( type.pretext() );
      pack_start( label, false, false, 0 );
    }

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

    pack_start( sbox, false, true, 0 );

    /* Default to three stars */
    set_stars( 3 );
        
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
  public override FileAction get_data() {
    var data  = new FileAction.with_type( _type );
    var stars = 0;
    for( int i=0; i<5; i++ ) {
      var img = (Image)_stars[i].image;
      stars += (img.icon_name == "starred") ? 2 : 0;
    }
    var token = new TextToken.with_text( stars.to_string() );
    data.token_text.add_token( token );
    return( data );
  }

  /* Sets the stars based on the given FileAction value */
  public override void set_data( FileAction data ) {
    var token = data.token_text.get_token( 0 );
    if( token.token_type == TextTokenType.TEXT ) {
      set_stars( int.parse( token.text ) / 2 );
    }
  }

}
