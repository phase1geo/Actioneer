using Gtk;
using Gdk;

public enum TokenModifyType {
  BEFORE,
  AFTER,
  REPLACE
}

public class TokenTextBox : Box {

  private Box      _tbox;
  private Overlay  _overlay;
  private Revealer _add_reveal;
  private bool     _id_used = false;
  private Widget?  _current = null;

  private bool       _move = false;
  private double     _move_offset = 0;
  private Widget?    _move_item = null;
  private int        _move_index;
  private int        _move_last_index;
  private Allocation _move_alloc;

  /* Default constructor */
  public TokenTextBox() {

    Object( orientation: Orientation.HORIZONTAL, spacing: 10 );

    var add = new Button.from_icon_name( "list-add-symbolic", IconSize.SMALL_TOOLBAR );
    add.set_tooltip_text( _( "Click to select token" ) );
    add.get_style_context().add_class( "circular" );
    add.get_style_context().add_class( "token" );
    add.clicked.connect(() => {
      Gtk.Menu menu;
      add_token_menu( out menu, null, TokenModifyType.BEFORE );
      menu.show_all();
      menu.popup_at_widget( add, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
    });
    _add_reveal = new Gtk.Revealer();
    _add_reveal.transition_type     = RevealerTransitionType.NONE;
    _add_reveal.transition_duration = 0;
    _add_reveal.reveal_child        = true;
    _add_reveal.add( add );
    pack_start( _add_reveal, false, false, 0 );

    _tbox = new Box( Orientation.HORIZONTAL, 2 );

    _overlay = new Overlay();
    _overlay.add( _tbox );

    var sw = new ScrolledWindow( null, null );
    sw.hscrollbar_policy = PolicyType.EXTERNAL;
    sw.vscrollbar_policy = PolicyType.NEVER;
    sw.hexpand = true;
    sw.hexpand_set = true;
    sw.add( _overlay );

    pack_start( sw, true, true, 0 );

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

  private int get_index_for_x( double x ) {
    var index = -1;
    var i     = 0;
    _tbox.get_children().foreach((b) => {
      Allocation alloc;
      b.get_allocation( out alloc );
      if( (alloc.x <= x) && (x < (alloc.x + alloc.width + 10)) ) {
        index = i;
      }
      i++;
    });
    return( index );
  }
  
  /* Inserts the given token */
  public void insert_token( int index, TextTokenType type, string? text, TextTokenModifier modifier, TextTokenFormat format ) {
    _add_reveal.reveal_child = false;
    var w = (type == TextTokenType.TEXT) ? insert_text( text ) : insert_button( type, modifier, format );
    w.key_press_event.connect((e) => {
      var control = (bool)(e.state & ModifierType.CONTROL_MASK);
      if( control ) {
        switch( e.keyval ) {
          case Gdk.Key.Left  :  move_token( -1 );  break;
          case Gdk.Key.Right :  move_token(  1 );  break;
        }
      } else {
        switch( e.keyval ) {
          case Gdk.Key.Left      :  change_select( -1 );       break;
          case Gdk.Key.Right     :  change_select(  1 );       break;
          case Gdk.Key.Escape    :  select_token( null );      break;
          case Gdk.Key.Delete    :  remove_token( type, 0 );   break;
          case Gdk.Key.BackSpace :  remove_token( type, -1 );  break;
          case Gdk.Key.space     :
          case Gdk.Key.Down      :  show_contextual_menu( w, type );  break;
        }
      }
      return( true );
    });
    w.focus_out_event.connect((e) => {
      if( (w == _current) && (Gtk.Menu.get_for_attach_widget( get_stylized_widget( w ) ).length() == 0) ) {
        select_token( null );
      }
      return( true );
    });
    w.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
        _move = true;
        _move_index = get_index( w );
        _move_last_index = _move_index;
        w.opacity = 0.0;
        w.get_allocation( out _move_alloc );
        _move_offset = e.x;
        _move_item = copy_widget( w );
        _move_item.margin_left = _move_alloc.x;
        _move_item.halign      = Align.START;
        _move_item.valign      = Align.FILL;
        _overlay.add_overlay( _move_item );
        _overlay.show_all();
      }
      return( true );
    });
    w.button_release_event.connect((e) => {
      if( _move ) {
        w.opacity = 1.0;
        _overlay.remove( _move_item );
        _overlay.show_all();
        _move = false;
      }
      return( true );
    });
    w.motion_notify_event.connect((e) => {
      if( _move ) {
        var idx  = get_index_for_x( e.x );
        var left = (int)((e.x - _move_offset) + _move_alloc.x);
        stdout.printf( "e.x: %g, move_offset: %g, move_alloc.x: %g, left: %d\n", e.x, _move_offset, _move_alloc.x, left );
        if( (left >= 0) && ((left + _move_alloc.width) < _tbox.get_allocated_width()) ) {
          _move_item.margin_left = left;
        }
        if( idx != _move_last_index ) {
          _tbox.reorder_child( w, idx );
          w.get_allocation( out _move_alloc );
        }
        _move_last_index = idx;
      }
      return( true );
    });
    _tbox.pack_start( w, false, false, 0 );
    if( (index + 1) < _tbox.get_children().length() ) {
      _tbox.reorder_child( w, index );
    }
  }

  private void add_token_menu( out Gtk.Menu menu, Widget? w, TokenModifyType type ) {
    menu = new Gtk.Menu();
    for( int i=0; i<TextTokenType.NUM; i++ ) {
      var token_type = (TextTokenType)i;
      if( (token_type == TextTokenType.UNIQUE_ID) && _id_used ) continue;
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
        show_all();
      });
      menu.add( item );
    }
    menu.show_all();
  }

  private void add_change_remove( Gtk.Menu menu, Widget w, TextTokenType type ) {

    Gtk.Menu submenu;

    var before = new Gtk.MenuItem.with_label( _( "Add Before" ) );
    add_token_menu( out submenu, w, TokenModifyType.BEFORE );
    before.submenu = submenu;

    var after  = new Gtk.MenuItem.with_label( _( "Add After" ) );
    add_token_menu( out submenu, w, TokenModifyType.AFTER );
    after.submenu = submenu;

    var replace = new Gtk.MenuItem.with_label( _( "Replace With" ) );
    add_token_menu( out submenu, w, TokenModifyType.REPLACE );
    replace.submenu = submenu;

    var remove = new Gtk.MenuItem.with_label( _( "Remove" ) );
    remove.activate.connect(() => {
      remove_token( type, 0 );
    });

    menu.add( before );
    menu.add( after );
    menu.add( replace );
    menu.add( remove );

  }

  private void add_id_format( Gtk.Menu menu, Widget w ) {
    for( int i=0; i<TextTokenFormat.NUM; i++ ) {
      var fmt  = (TextTokenFormat)i;
      var item = new Gtk.MenuItem.with_label( fmt.label() );
      item.activate.connect(() => {
        var btn = (Button)w;
        btn.label = fmt.label();
      });
      menu.add( item );
    }
  }

  private void add_modifiers( Gtk.Menu menu, Widget w ) {
    for( int i=0; i<TextTokenModifier.NUM; i++ ) {
      var mod  = (TextTokenModifier)i;
      var item = new Gtk.MenuItem.with_label( mod.label() );
      item.activate.connect(() => {
        var btn = (Button)w;
        var nmod = TextTokenModifier.TITLE;
        btn.label = mod.format( nmod.format( btn.label ) );
      });
      menu.add( item );
    }
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

  private void show_text_context_menu( EventBox ebox ) {
    var frame = (Frame)ebox.get_child();
    var label = (Label)frame.get_child();
    var menu  = new Gtk.Menu();
    menu.attach_widget = frame;
    var edit = new Gtk.MenuItem.with_label( _( "Edit..." ) );
    edit.activate.connect(() => {
      edit_text( label );
    });
    menu.add( edit );
    menu.add( new SeparatorMenuItem() );
    add_change_remove( menu, ebox, TextTokenType.TEXT );
    menu.show_all();
    menu.popup_at_widget( frame, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
  }

  private void show_button_context_menu( Button btn, TextTokenType type ) {
    var is_id  = (type == TextTokenType.UNIQUE_ID);
    var is_sep = (type == TextTokenType.DIR_SEP);
    var menu = new Gtk.Menu();
    menu.attach_widget = btn;
    if( is_id ) {
      add_id_format( menu, btn );
    } else if( !is_sep ) {
      add_modifiers( menu, btn );
    }
    menu.add( new SeparatorMenuItem() );
    add_change_remove( menu, btn, type );
    menu.show_all();
    menu.popup_at_widget( btn, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
  }

  private void show_contextual_menu( Widget w, TextTokenType type ) {
    if( (w as Button) != null ) {
      show_button_context_menu( (w as Button), type );
    } else {
      show_text_context_menu( (w as EventBox) );
    }
  }

  /* Inserts a text entry */
  private Widget insert_text( string? text ) {
    var label = new Label( text ?? "" );
    label.margin_left  = 3;
    label.margin_right = 3;
    var frame = new Frame( null );
    frame.add( label );
    frame.get_style_context().add_class( "token" );
    var ebox = new EventBox();
    ebox.can_focus = true;
    ebox.add( frame );
    ebox.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_SECONDARY ) {
        select_token( ebox );
        show_text_context_menu( ebox );
      }
      return( false );
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
    var is_id  = (type == TextTokenType.UNIQUE_ID);
    var is_sep = (type == TextTokenType.DIR_SEP);
    var label  = mod.format( type.label() );
    if( is_sep ) {
      label = Path.DIR_SEPARATOR_S;
    } else if( is_id ) {
      label = fmt.label();
    }
    var btn = new Button.with_label( label );
    btn.get_style_context().add_class( "circular" );
    btn.get_style_context().add_class( "token" );
    btn.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_SECONDARY ) {
        select_token( btn );
        show_button_context_menu( btn, type );
      }
      return( false );
    });
    if( is_id ) {
      _id_used = true;
    }
    return( btn );
  }

  private Widget get_stylized_widget( Widget w ) {
    var ebox = w as EventBox;
    if( ebox != null ) {
      return( ebox.get_child() );
    } else {
      return( w );
    }
  }

  private Widget copy_widget( Widget w ) {
    var ebox = w as EventBox;
    if( ebox != null ) {
      var frame      = (Frame)ebox.get_child();
      var orig_label = (Label)frame.get_child();
      var new_label  = new Label( orig_label.label );
      new_label.margin_left  = 3;
      new_label.margin_right = 3;
      var new_frame = new Frame( null );
      new_frame.add( new_label );
      new_frame.get_style_context().add_class( "token" );
      return( new_frame );
    } else {
      var orig_btn = (Button)w;
      var new_btn  = new Button.with_label( orig_btn.label );
      new_btn.get_style_context().add_class( "circular" );
      new_btn.get_style_context().add_class( "token" );
      return( new_btn );
    }
  }

  private void remove_token( TextTokenType type, int select_dir ) {

    var next = get_current_pos() + select_dir;
    if( next == -1 ) {
      next = 0;
    } else if( (next + 1) == _tbox.get_children().length() ) {
      next--;
    }

    /* Remove the token */
    _tbox.remove( _current ); 

    /* Reveal the "add" button if the token list is empty */
    if( _tbox.get_children().length() == 0 ) {
      _add_reveal.reveal_child = true;
    } else {
      select_token( _tbox.get_children().nth_data( next ) );
    }

    /* If the UNIQUE_ID token is removed, clear the id_used indicator */
    if( type == TextTokenType.UNIQUE_ID ) {
      _id_used = false;
    }

    /* Update the UI */
    show_all();

  }

  private void select_token( Widget? token ) {
    if( _current != null ) {
      get_stylized_widget( _current ).get_style_context().remove_class( "selected" );
    }
    if( token != null ) {
      get_stylized_widget( token ).get_style_context().add_class( "selected" );
    }
    _current = token;
    if( _current != null ) {
      _current.grab_focus();
    }
  }

  private int get_current_pos() {
    int index = 0;
    for( int i=0; i<_tbox.get_children().length(); i++ ) {
      if( _tbox.get_children().nth_data( i ) == _current ) {
        return( i );
      }
    }
    return( -1 );
  }

  private void move_token( int dir ) {
    var pos = get_current_pos();
    if( ((pos + dir) >= 0) && ((pos + dir) < _tbox.get_children().length()) ) {
      _tbox.reorder_child( _current, (pos + dir) );
    }
  }

  private void change_select( int dir ) {
    var pos = get_current_pos();
    if( ((pos + dir) >= 0) && ((pos + dir) < _tbox.get_children().length()) ) {
      select_token( _tbox.get_children().nth_data( pos + dir ) );
    }
  }

  public void get_data( TokenText token_text ) {
    _tbox.get_children().foreach((w) => {
      if( (w as EventBox) != null ) {
        var ebox  = (EventBox)w;
        var frame = (Frame)ebox.get_child();
        var lbl   = (Label)frame.get_child();
        var token = new TextToken.with_text( lbl.label );
        token_text.add_token( token );
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
                token_text.add_token( token );
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
                token_text.add_token( token );
                found = true;
                break;
              }
            }
          }
          i++;
        }
      }
    });
  }

  public void set_data( TokenText? token_text, int start_token = 0 ) {
    _tbox.get_children().foreach((w) => {
      _tbox.remove( w );
    });
    if( token_text == null ) {
      _add_reveal.reveal_child = true;
    } else {
      for( int i=start_token; i<token_text.num_tokens(); i++ ) {
        var token = token_text.get_token( i );
        insert_token( i, token.token_type, token.text, token.modifier, token.id_format );
      }
      _tbox.show_all();
    }
  }

}
