using Gtk;
using Gdk;

public enum TokenItemType {
  VARIABLE,  // Circular item that displays its name only
  SUBTOKEN,  // Circular item
  LITERAL    // Text item
}

public enum TokenModifier {
  BEFORE,
  AFTER,
  REPLACE
}

public class TokenBox : Box {

  private Box      _tbox;
  private Revealer _add_reveal;

  /* Default constructor */
  public TokenBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 0 );

    var add = new Button.from_icon_name( "list-add-symbolic", IconSize.SMALL_TOOLBAR );
    add.get_style_context().add_class( "add-item" );
    add.clicked.connect(() => {
      var menu = new Gtk.Menu();
      add_token_menu( menu, null, TokenModifier.BEFORE );
      menu.popup_at_widget( add, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
    });
    _add_reveal = new Revealer();
    _add_reveal.reveal_child = true;
    _add_reveal.add( add );

    _tbox = new Box( Orientation.HORIZONTAL, 2 );

    var sw = new ScrolledWindow( null, null );
    sw.hscrollbar_policy = PolicyType.EXTERNAL;
    sw.vscrollbar_policy = PolicyType.NEVER;
    sw.hexpand = true;
    sw.hexpand_set = true;
    sw.add( _tbox );

    pack_start( _add_reveal, false, false, 0 );
    pack_start( sw,          true,  true,  0 );

  }

  /* Returns the index of the given widget in the tbox */
  private int get_index( Widget? w ) {
    var index = -1;
    if( w != null ) {
      var i = 0;
      _tbox.get_children().foreach((item) => {
        if( item == w ) {
          index = i;
        }
        i++;
      });
    }
    return( index );
  }

  /* Inserts the given token */
  public void insert_token( int index, TokenItemType type, string label ) {
    Widget w;
    switch( type ) {
      case TokenItemType.VARIABLE :  w = insert_variable( label );   break;
      case TokenItemType.SUBTOKEN :  w = insert_subtoken( label );  break;
      case TokenItemType.LITERAL  :  w = insert_literal( label );    break;
      default                     :  assert_not_reached();
    }
    _tbox.pack_start( w, false, false, 0 );
    if( (index + 1) < _tbox.get_children().length() ) {
      _tbox.reorder_child( w, index );
    }
  }

  /* Inserts a conversion button */
  private Widget insert_variable( string lbl ) {

    var btn = new Button.with_label( lbl );
    btn.get_style_context().add_class( "circular" );
    btn.get_style_context().add_class( "token" );
    btn.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {
        show_variable_menu( btn );
      }
      return( true );
    });

    return( btn );

  }

  /* Displays the variable menu */
  private void show_variable_menu( Button btn ) {

    var menu = new Gtk.Menu();

    add_modifiers( menu, btn );
    menu.add( new SeparatorMenuItem() );
    add_change_remove( menu, btn );
    menu.show_all();

    menu.popup_at_widget( btn, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );

  }

  /* Inserts a conversion button */
  private Widget insert_subtoken( string lbl ) {

    var btn = new Button.with_label( lbl );
    btn.get_style_context().add_class( "circular" );
    btn.get_style_context().add_class( "token" );
    btn.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {
        show_subtoken_menu( btn );
      }
      return( true );
    });

    Idle.add(() => {
      edit_tokens( btn );
      return( false );
    });

    return( btn );

  }

  /* Displays the menu for a formatter type */
  private void show_subtoken_menu( Button btn ) {

    var menu = new Gtk.Menu();

    var edit = new Gtk.MenuItem.with_label( _( "Edit..." ) );
    edit.activate.connect(() => {
      edit_tokens( btn );
    });

    menu.add( new SeparatorMenuItem() );
    add_change_remove( menu, btn );
    menu.show_all();

    menu.popup_at_widget( btn, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );

  }

  /* Allows the token to be edited */
  private void edit_tokens( Button btn ) {

    var tbox = new TokenBox();

    var popover = new Popover( btn );

    popover.add( tbox );
    popover.show_all();
    popover.popup();

  }

  /* Inserts a text entry */
  private Widget insert_literal( string? lbl ) {

    var label = new Label( lbl ?? "" );
    label.margin_left  = 3;
    label.margin_right = 3;

    var frame = new Frame( null );
    frame.get_style_context().add_class( "token" );
    frame.add( label );

    var ebox = new EventBox();
    ebox.add( frame );
    ebox.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
        // Start a drag event?
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {
        show_literal_menu( frame );
      }
      return( true );
    });

    if( lbl == null ) {
      Idle.add(() => {
        edit_literal( label );
        return( false );
      });
    }
    return( ebox );
  }

  /* Allows the literal text to be edited */
  private void edit_literal( Label label ) {

    var entry = new Entry();
    entry.text = label.label;

    var popover = new Popover( label );

    entry.key_press_event.connect((e) => {
      if( e.keyval == Gdk.Key.Return ) {
        label.label = entry.text;
        popover.popdown();
        return( true );
      }
      return( false );
    });

    popover.add( entry );
    popover.show_all();
    popover.popup();

  }

  /* Displays the menu for a literal menu */
  private void show_literal_menu( Frame frame ) {

    var menu = new Gtk.Menu();

    var edit = new Gtk.MenuItem.with_label( _( "Edit..." ) );
    edit.activate.connect(() => {
      edit_literal( (Label)frame.get_child() );
    });

    menu.add( edit );
    menu.add( new SeparatorMenuItem() );
    add_change_remove( menu, frame );
    menu.show_all();
    menu.popup_at_widget( frame, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );

  }

  private void add_token_menu( Gtk.Menu menu, Widget? w, TokenModifier type ) {
    var index = get_index( w );
    for( int i=0; i<num_items(); i++ ) {
      var item       = new Gtk.MenuItem.with_label( item_label( i ) );
      var token_type = item_type( i );
      var label      = (token_type == TokenItemType.LITERAL) ? "" : item_label( i );
      item.activate.connect(() => {
        switch( type ) {
          case TokenModifier.BEFORE  :
            insert_token( index, token_type, label );
            break;
          case TokenModifier.AFTER   :
            insert_token( (index + 1), token_type, label );
            break;
          case TokenModifier.REPLACE :
            _tbox.remove( w );
            insert_token( index, token_type, label );
            break;
        }
        show_all();
      });
      menu.add( item );
    }
    menu.show_all();
  }

  private void add_change_remove( Gtk.Menu menu, Widget w ) {

    var before = new Gtk.MenuItem.with_label( _( "Add Before" ) );
    before.submenu = new Gtk.Menu();
    add_token_menu( before.submenu, w, TokenModifier.BEFORE );

    var after = new Gtk.MenuItem.with_label( _( "Add After" ) );
    after.submenu = new Gtk.Menu();
    add_token_menu( after.submenu, w, TokenModifier.AFTER );

    var replace = new Gtk.MenuItem.with_label( _( "Replace With" ) );
    replace.submenu = new Gtk.Menu();
    add_token_menu( replace.submenu, w, TokenModifier.REPLACE );

    var remove = new Gtk.MenuItem.with_label( _( "Remove" ) );
    remove.activate.connect(() => {
      _tbox.remove( w ); 
      if( _tbox.get_children().length() == 0 ) {
        _add_reveal.reveal_child = true;
      }
      show_all();
    });

    menu.add( before );
    menu.add( after );
    menu.add( replace );
    menu.add( remove );

  }

  private void add_modifiers( Gtk.Menu menu, Widget w ) {
    for( int i=0; i<TextTokenModifier.NUM; i++ ) {
      var mod  = (TextTokenModifier)i;
      var item = new Gtk.MenuItem.with_label( mod.label() );
      item.activate.connect(() => {
        var btn = (Button)w;
        btn.label = mod.format( btn.label );
      });
      menu.add( item );
    }
  }

  protected virtual int num_items() {
    assert( false );
    return( 0 );
  }

  protected virtual string item_label( int index ) {
    assert( false );
    return( "" );
  }

  protected virtual TokenItemType item_type( int index ) {
    assert( false );
    return( TokenItemType.LITERAL );
  }

  /*
  public override FileAction get_data() {
    var data = new FileAction.with_type( _type );
    _tbox.get_children().foreach((w) => {
      if( (w as EventBox) != null ) {
        var ebox  = (EventBox)w;
        var frame = (Frame)ebox.get_child();
        var lbl   = (Label)frame.get_child();
        var token = new TextToken.with_text( lbl.label );
        data.token_text.add_token( token );
      } else if( (w as Button) != null ) {
        var btn   = (Button)w;
        var found = false;
        var i     = 0;
        while( (i < TextTokenType.NUM) && !found ) {
          var type = (TextTokenType)i;
          for( int j=0; j<TextTokenModifier.NUM; j++ ) {
            var mod = (TextTokenModifier)j;
            if( btn.label == mod.format( type.label() ) ) {
              var token = new TextToken.with_type( type );
              token.modifier = mod;
              data.token_text.add_token( token );
              found = true;
              break;
            }
          }
          i++;
        }
      }
    });
    return( data );
  }

  public override void set_data( FileAction data ) {
    _tbox.get_children().foreach((w) => {
      _tbox.remove( w );
    });
    var token_text = data.token_text;
    if( token_text == null ) {
      _add_reveal.reveal_child = true;
    } else {
      for( int i=0; i<token_text.num_tokens(); i++ ) {
        var token = token_text.get_token( i );
        insert_token( i, token.token_type, token.text, token.modifier );
      }
      _tbox.show_all();
    }
  }
  */

}
