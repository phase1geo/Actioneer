using Gtk;
using Gdk;

public enum TokenModifyType {
  BEFORE,
  AFTER,
  REPLACE
}

public class ActionRenameBox : ActionBase {

  private Box      _tbox;
  private Revealer _add_reveal;
  private bool     _id_used = false;

  /* Default constructor */
  public ActionRenameBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );

    GLib.Menu menu;
    add_token_menu( out menu, null, TokenModifyType.BEFORE );

    var add = new MenuButton() {
      icon_name    = "list-add-symbolic",
      tooltip_text = _( "Click to select filename rename token" ),
      menu_model   = menu
    };
    add.get_style_context().add_class( "circular" );
    add.get_style_context().add_class( "token" );

    _add_reveal = new Gtk.Revealer() {
      transition_type     = RevealerTransitionType.NONE,
      transition_duration = 0,
      child               = add
    };

    _tbox = new Box( Orientation.HORIZONTAL, 2 );

    var sw = new ScrolledWindow() {
      hscrollbar_policy = PolicyType.EXTERNAL,
      vscrollbar_policy = PolicyType.NEVER,
      hexpand = true,
      child = _tbox
    };

    append( label );
    append( _add_reveal );
    append( sw );

    /* Create default tokens */
    insert_token( 0, TextTokenType.FILE_BASE, null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
    insert_token( 1, TextTokenType.TEXT,      ".",  TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
    insert_token( 2, TextTokenType.FILE_EXT,  null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );

  }

  /* Returns the index of the given widget in the tbox */
  private int get_index( Widget? w ) {
    if( w != null ) {
      var i = 0;
      var child = _tbox.get_first_child();
      while( (child != null) && (child != w) ) {
        child = child.get_next_sibling();
        i++;
      }
      if( child != null ) {
        return( i );
      }
    }
    return( -1 );
  }

  /* Inserts the given token */
  private void insert_token( int index, TextTokenType type, string? text, TextTokenModifier modifier, TextTokenFormat format ) {
    _add_reveal.reveal_child = false;
    var w = (type == TextTokenType.TEXT) ? insert_text( text ) : insert_button( type, modifier, format );
    _tbox.pack_start( w, false, false, 0 );
    if( (index + 1) < _tbox.get_children().length() ) {
      _tbox.reorder_child( w, index );
    }
  }

  private void add_token_menu( out GLib.Menu menu, Widget? w, TokenModifyType type ) {
    menu = new GLib.Menu();
    for( int i=0; i<TextTokenType.NUM; i++ ) {
      var token_type = (TextTokenType)i;
      if( (token_type == TextTokenType.UNIQUE_ID) && _id_used ) continue;
      switch( type ) {
        case TokenModifyType.BEFORE  :  menu.append( token_type.label(), "rename.action_add_before(%d)".printf( index ) );  break;
        case TokenModifyType.AFTER   :  menu.append( token_type.label(), "rename.action_add_after(%d)".printf( index + 1 ) );  break;
        case TokenModifyType.REPLACE :  menu.append( token_type.label(), "rename.action_add_replace(%d)".printf( index ) );  break;
      }
      var item       = new Gtk.MenuItem.with_label( token_type.label() );
      var mtype      = type;
      item.activate.connect(() => {
        var index = get_index( w );
        switch( mtype ) {
          case TokenModifyType.BEFORE  :
            insert_token( index, token_type, null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
            break;
          case TokenModifyType.AFTER   :
            insert_token( (index + 1), token_type, null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
            break;
          case TokenModifyType.REPLACE :
            _tbox.remove( w );
            insert_token( index, token_type, null, TextTokenModifier.NONE, TextTokenFormat.NO_ZERO );
            break;
        }
      });
      menu.append( token_type.label(), "rename.action_add_token('%d:%d')".printf( i, i ) );
    }
  }

  private void add_change_remove( GLib.Menu menu, Widget w, TextTokenType type ) {

    GLib.Menu submenu;
    GLib.Menu before, after, replace;

    add_token_menu( out before,  w, TokenModifyType.BEFORE );
    add_token_menu( out after,   w, TokenModifyType.AFTER );
    add_token_menu( out replace, w, TokenModifyType.REPLACE );

    var remove = new Gtk.MenuItem.with_label( _( "Remove" ) );
    remove.activate.connect(() => {
      _tbox.remove( w ); 
      if( _tbox.get_children().length() == 0 ) {
        _add_reveal.reveal_child = true;
      }
      if( type == TextTokenType.UNIQUE_ID ) {
        _id_used = false;
      }
      show_all();
    });

    menu.append_submenu( _( "Add Before" ),   before );
    menu.append_submenu( _( "Add After" ),    after );
    menu.append_submenu( _( "Replace With" ), replace );
    menu.append( _( "Remove" ), "rename.action_remove" );

  }

  private GLib.Menu add_id_format( Widget w ) {
    var menu = new GLib.Menu();
    for( int i=0; i<TextTokenFormat.NUM; i++ ) {
      var fmt  = (TextTokenFormat)i;
      var item = new Gtk.MenuItem.with_label( fmt.label() );
      item.activate.connect(() => {
        var btn = (Button)w;
        btn.label = fmt.label();
      });
      menu.append( item );
    }
    return( menu );
  }

  private GLib.Menu add_modifiers( Gtk.Menu menu, Widget w ) {
    var menu = new GLib.Menu();
    for( int i=0; i<TextTokenModifier.NUM; i++ ) {
      var mod  = (TextTokenModifier)i;
      var item = new Gtk.MenuItem.with_label( mod.label() );
      item.activate.connect(() => {
        var btn = (Button)w;
        btn.label = mod.format( btn.label );
      });
      menu.append( item );
    }
    return( menu );
  }

  private void edit_text( Label label ) {

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

  /* Inserts a text entry */
  private Widget insert_text( string? text ) {
    var click = new GestureClick() {
      button = Gdk.BUTTON_SECONDARY
    };
    var frame = new Frame( text ?? "" );
    frame.add_controller( click );
    frame.get_style_context().add_class( "token" );
    click.pressed.connect((n_press, x, y) => {
      var menu = new Gtk.Menu();
      var edit = new Gtk.MenuItem.with_label( _( "Edit..." ) );
      edit.activate.connect(() => {
        edit_text( label );
      });
      menu.add( edit );
      menu.add( new SeparatorMenuItem() );
      add_change_remove( menu, ebox, TextTokenType.TEXT );
      menu.popup_at_widget( frame, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
    });
    var ebox = new EventBox();
    ebox.add( frame );
    ebox.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
        // Start a drag event?
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {

      }
      return( true );
    });
    if( text == null ) {
      Idle.add(() => {
        edit_text( label );
        return( false );
      });
    }
    return( ebox );
  }

  /* Inserts a conversion button */
  private Widget insert_button( TextTokenType type, TextTokenModifier mod, TextTokenFormat fmt ) {
    var is_id = (type == TextTokenType.UNIQUE_ID);
    var btn   = new Button.with_label( is_id ? fmt.label() : mod.format( type.label() ) );
    btn.get_style_context().add_class( "circular" );
    btn.get_style_context().add_class( "token" );
    btn.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {
        var menu = new GLib.Menu();
        if( is_id ) {
          menu.append_section( null, add_id_format( btn ) );
        } else {
          menu.append_section( null, add_modifiers( btn ) );
        }
        menu.append_section( null, add_change_remove( btn, type );
        menu.popup_at_widget( btn, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
      }
      return( true );
    });
    if( is_id ) {
      _id_used = true;
    }
    return( btn );
  }

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
          if( type == TextTokenType.UNIQUE_ID ) {
            for( int j=0; j<TextTokenFormat.NUM; j++ ) {
              var fmt = (TextTokenFormat)j;
              if( btn.label == fmt.label() ) {
                var token = new TextToken.with_type( type );
                token.id_format = fmt;
                data.token_text.add_token( token );
                found = true;
                break;
              }
            }
          } else {
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
        insert_token( i, token.token_type, token.text, token.modifier, token.id_format );
      }
      _tbox.show_all();
    }
  }

}
