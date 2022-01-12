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

  /* Default constructor */
  public ActionRenameBox( FileActionType type ) {

    base( type );

    var label = new Label( type.pretext() );
    pack_start( label, false, false, 0 );

    _tbox = new Box( Orientation.HORIZONTAL, 2 );

    var sw = new ScrolledWindow( null, null );
    sw.hscrollbar_policy = PolicyType.EXTERNAL;
    sw.vscrollbar_policy = PolicyType.NEVER;
    sw.hexpand = true;
    sw.hexpand_set = true;
    sw.add( _tbox );

    pack_start( sw, true, true, 0 );

    var add = new Button.from_icon_name( "list-add-symbolic", IconSize.SMALL_TOOLBAR );
    add.get_style_context().add_class( "circular" );
    add.clicked.connect(() => {
      Gtk.Menu menu;
      add_token_menu( out menu, null, TokenModifyType.BEFORE );
      menu.show_all();
      menu.popup_at_widget( add, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
    });
    _add_reveal = new Gtk.Revealer();
    _add_reveal.transition_type     = RevealerTransitionType.NONE;
    _add_reveal.transition_duration = 0;
    _add_reveal.add( add );
    pack_start( _add_reveal, false, false, 0 );

    /* Create default tokens */
    insert_token( 0, TextTokenType.FILE_BASE, null, TextTokenModifier.NONE );
    insert_token( 1, TextTokenType.TEXT, ".", TextTokenModifier.NONE );
    insert_token( 2, TextTokenType.FILE_EXT, null, TextTokenModifier.NONE );

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
  private void insert_token( int index, TextTokenType type, string? text, TextTokenModifier modifier ) {
    _add_reveal.reveal_child = false;
    var w = (type == TextTokenType.TEXT) ? insert_text( text ) : insert_button( type );
    _tbox.pack_start( w, false, false, 0 );
    if( (index + 1) < _tbox.get_children().length() ) {
      _tbox.reorder_child( w, index );
    }
  }

  private void add_token_menu( out Gtk.Menu menu, Widget? w, TokenModifyType type ) {
    menu = new Gtk.Menu();
    for( int i=0; i<TextTokenType.NUM; i++ ) {
      var token_type = (TextTokenType)i;
      var item       = new Gtk.MenuItem.with_label( token_type.label() );
      var mtype      = type;
      item.activate.connect(() => {
        var index = get_index( w );
        switch( mtype ) {
          case TokenModifyType.BEFORE  :
            insert_token( index, token_type, null, TextTokenModifier.NONE );
            break;
          case TokenModifyType.AFTER   :
            insert_token( (index + 1), token_type, null, TextTokenModifier.NONE );
            break;
          case TokenModifyType.REPLACE :
            _tbox.remove( w );
            insert_token( index, token_type, null, TextTokenModifier.NONE );
            break;
        }
        show_all();
      });
      menu.add( item );
    }
    menu.show_all();
  }

  private void add_change_remove( Gtk.Menu menu, Widget w ) {

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
      _tbox.remove( w ); 
      if( _tbox.get_children().length() == 0 ) {
        _add_reveal.reveal_child = false;
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
    var label = new Label( text ?? "" );
    label.margin_left  = 3;
    label.margin_right = 3;
    var frame = new Frame( null );
    frame.add( label );
    var ebox = new EventBox();
    ebox.add( frame );
    ebox.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
        // Start a drag event?
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {
        var menu = new Gtk.Menu();
        var edit = new Gtk.MenuItem.with_label( _( "Edit..." ) );
        edit.activate.connect(() => {
          edit_text( label );
        });
        menu.add( edit );
        menu.add( new SeparatorMenuItem() );
        add_change_remove( menu, ebox );
        menu.show_all();
        menu.popup_at_widget( frame, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
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
  private Widget insert_button( TextTokenType type ) {
    var btn = new Button.with_label( type.label() );
    btn.get_style_context().add_class( "circular" );
    btn.button_press_event.connect((e) => {
      if( e.button == Gdk.BUTTON_PRIMARY ) {
      } else if( e.button == Gdk.BUTTON_SECONDARY ) {
        var menu = new Gtk.Menu();
        add_modifiers( menu, btn );
        menu.add( new SeparatorMenuItem() );
        add_change_remove( menu, btn );
        menu.show_all();
        menu.popup_at_widget( btn, Gravity.SOUTH_WEST, Gravity.NORTH_WEST );
      }
      return( true );
    });
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
    var token_text = data.token_text;
    for( int i=0; i<token_text.num_tokens(); i++ ) {
      var token = token_text.get_token( i );
      insert_token( i, token.token_type, token.text, token.modifier );
    }
  }

}
