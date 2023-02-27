public enum SearchOpType {
  AND,
  OR,
  NOT,
  VALUE,
  KEY_VALUE,
  SUBEXP,
  NUM;

  public string to_string() {
    switch( this ) {
      case AND       :  return( "AND" );
      case OR        :  return( "OR" );
      case NOT       :  return( "NOT" );
      case VALUE     :  return( "VALUE" );
      case KEY_VALUE :  return( "KEY/VALUE" );
      case SUBEXP    :  return( "SUBEXP" );
      default        :  assert_not_reached();
    }
  }

  public bool contains_result() {
    return( (this == VALUE) || (this == KEY_VALUE) || (this == SUBEXP) );
  }

}

public class SearchCompletion {

  private int    _spos;
  private bool   _quoted;
  private string _old;
  private string _new;

  public string text {
    get {
      return( _new );
    }
  }

  /* Default constructor */
  public SearchCompletion( int spos, bool quoted, string old_str, string new_str ) {
    _spos   = spos;
    _quoted = quoted;
    _old    = old_str;
    _new    = new_str;
  }

  private string get_new() {
    return( _new.contains( " " ) ? ("\"" + _new + "\"") : _new );
  }

  /* Returns the search string with the replacement performed */
  public string get_replacement_string( string original ) {
    var spos = original.index_of_nth_char( get_spos() );
    var epos = original.index_of_nth_char( _spos + _old.char_count() + (_quoted ? 1 : 0) );
    return( original.splice( spos, epos, get_new() ) );
  }

  public string get_label() {
    return( _new );
  }

  /* Returns the starting character index that will be replaced */
  public int get_spos() {
    return( _spos - (_quoted ? 1 : 0) );
  }

  /* Returns the ending character index that will be replaced */
  public int get_epos() {
    return( _spos + get_new().char_count() );
  }

}

public class SearchOp {

  public SearchOpType op   { get; private set; default = SearchOpType.NUM; }
  public int          spos { get; private set; default = 0; }

  /* Default constructor */
  public SearchOp( SearchOpType op, int spos ) {
    this.op   = op;
    this.spos = spos;
  }

  public virtual bool check_match( DirAction rule ) {
    return( true );
  }

  private void check_and_add_completer( string label, string text, PatternSpec text_pattern, bool quoted,
                                        ref SList<SearchCompletion> completers ) {
    if( label.down() != text.down() ) {
      if( text_pattern.match_string( label.down() ) ) {
        completers.append( new SearchCompletion( spos, quoted, text, label ) );
      }
    }
  }

  protected void get_matching_completers( string text, PatternSpec text_pattern, bool quoted,
                                          ref SList<SearchCompletion> completers ) {
    for( int i=0; i<ActionConditionType.NUM; i++ ) {
      var type = (ActionConditionType)i;
      check_and_add_completer( type.label(), text, text_pattern, quoted, ref completers );
    }
    for( int i=0; i<FileActionType.NUM; i++ ) {
      var type = (FileActionType)i;
      check_and_add_completer( type.label(), text, text_pattern, quoted, ref completers );
    }
  }

  public virtual bool get_completers( int curpos, ref SList<SearchCompletion> completers ) {
    return( false );
  }

  public virtual string to_string( string prefix ) {
    return( "%s, spos: %d".printf( op.to_string(), spos ) );
  }

}

public class SearchOpAnd : SearchOp {
  public SearchOpAnd( int spos ) {
    base( SearchOpType.AND, spos );
  }
}

public class SearchOpOr : SearchOp {
  public SearchOpOr( int spos ) {
    base( SearchOpType.OR, spos );
  }
}

public class SearchOpNot : SearchOp {
  public SearchOpNot( int spos ) {
    base( SearchOpType.NOT, spos );
  }
}

public class SearchOpValue : SearchOp {
  private bool        _quoted;
  private string      _val;
  private PatternSpec _pattern;
  public SearchOpValue( int spos, bool quoted, string val ) {
    base( SearchOpType.VALUE, spos );
    _quoted  = quoted;
    _val     = val;
    _pattern = new PatternSpec( "*" + val.down() + "*" );
  }
  public bool matches( DirAction rule ) {
    for( int i=0; i<rule.conditions.size(); i++ ) {
      var cond = rule.conditions.get_condition( i );
      if( cond.matches( null, _pattern ) ) {
        return( true );
      }
    }
    for( int i=0; i<rule.actions.size(); i++ ) {
      var act = rule.actions.get_action( i );
      if( act.matches( _pattern ) ) {
        return( true );
      }
    }
    return( _pattern.match_string( rule.name ) );
  }
  public override bool check_match( DirAction rule ) {
    return( matches( rule ) );
  }
  public override bool get_completers( int curpos, ref SList<SearchCompletion> completers ) {
    if( (spos <= curpos) && (curpos <= (spos + _val.char_count())) ) {
      get_matching_completers( _val, _pattern, _quoted, ref completers );
      return( true );
    }
    return( false );
  }
  public override string to_string( string prefix ) {
    return( "%s, spos: %d, quoted: %s (%s)".printf( op.to_string(), spos, _quoted.to_string(), _val ) );
  }
}

public class SearchOpKeyValue : SearchOp {
  private bool        _quoted;
  private string      _key;
  private string      _val;
  private PatternSpec _kpattern;
  private PatternSpec _vpattern;
  public SearchOpKeyValue( int spos, bool quoted, string key, string val ) {
    base( SearchOpType.KEY_VALUE, spos );
    _quoted  = quoted;
    _key     = key;
    _val     = val;
    _kpattern = new PatternSpec( "*" + key.down() + "*" );
    _vpattern = new PatternSpec( "*" + val.down() + "*" );
  }
  public bool matches( DirAction rule ) {
    var cond_type = ActionConditionType.match_to_label( _key );
    var act_type  = FileActionType.match_to_label( _key );
    if( cond_type != ActionConditionType.NUM ) {
      for( int i=0; i<rule.conditions.size(); i++ ) {
        var cond = rule.conditions.get_condition( i );
        if( cond.cond_type == cond_type ) {
          return( cond.matches( cond_type, _vpattern ) );
        }
      }
    } else if( act_type != FileActionType.NUM ) {
      for( int i=0; i<rule.actions.size(); i++ ) {
        var act = rule.actions.get_action( i );
        if( act.action_type == act_type ) {
          return( act.matches( _vpattern ) );
        }
      }
    } else {
      return( _kpattern.match_string( rule.name ) );
    }
    return( false );
  }
  public override bool check_match( DirAction rule ) {
    return( matches( rule ) );
  }
  public override bool get_completers( int curpos, ref SList<SearchCompletion> completers ) {
    if( (spos <= curpos) && (curpos <= (spos + _key.char_count())) ) {
      get_matching_completers( _key, _kpattern, _quoted, ref completers );
      return( true );
    }
    return( false );
  }
  public override string to_string( string prefix ) {
    var cond_type = ActionConditionType.match_to_label( _key );
    var act_type  = FileActionType.match_to_label( _key );
    return( "%s, spos: %d, quoted: %s (c: %s, a: %s, v: %s)".printf(
        op.to_string(),
        spos, _quoted.to_string(),
        ((cond_type == ActionConditionType.NUM) ? "" : cond_type.to_string()),
        ((act_type  == FileActionType.NUM)      ? "" : act_type.to_string()),
        _val
      )
    );
  }
}

public class SearchSubexp : SearchOp {

  private SList<SearchOp> _ops;

  public SearchSubexp( int spos ) {
    base( SearchOpType.SUBEXP, spos );
    _ops = new SList<SearchOp>();
  }

  public void add_and( int spos ) {
    var op = new SearchOpAnd( spos );
    _ops.append( op );
  }

  public void add_or( int spos ) {
    var op = new SearchOpOr( spos );
    _ops.append( op );
  }

  public void add_not( int spos ) {
    var op = new SearchOpNot( spos );
    _ops.append( op );
  }

  public void add_key_value( int spos, bool quoted, ref string key, ref string val ) {
    if( val != "" ) {
      SearchOp op;
      if( key != "" ) {
        op = new SearchOpKeyValue( spos, quoted, key, val );
      } else {
        switch( val.down() ) {
          case "and" :  op = new SearchOpAnd( spos );                 break;
          case "or"  :  op = new SearchOpOr( spos );                  break;
          default    :  op = new SearchOpValue( spos, quoted, val );  break;
        }
      }
      _ops.append( op );
      key = "";
      val = "";
    }
  }

  public void add_subexp( SearchSubexp subexp ) {
    _ops.append( subexp );
  }

  /* Returns true if the subexpression matches the rule conditions/actions */
  public bool matches( DirAction rule ) {
    var last_op = SearchOpType.NUM;
    var res     = true;
    for( int i=0; i<_ops.length(); i++ ) {
      var op   = _ops.nth_data( i );
      var cres = op.check_match( rule );
      if( op.op.contains_result() ) {
        if( last_op == SearchOpType.NOT ) {
          cres = !cres;
        }
      } else if( op.op == SearchOpType.AND ) {
        if( !res && last_op.contains_result() ) {
          return( false );
        }
      } else if( op.op == SearchOpType.OR ) {
        if( res && last_op.contains_result() ) {
          return( true );
        }
      }
      res = cres;
      last_op = op.op;
    }
    return( res );
  }

  public override bool check_match( DirAction rule ) {
    return( matches( rule ) );
  }

  public void get_completers( int curpos, ref SList<SearchCompletion> completers ) {
    for( int i=0; i<_ops.length(); i++ ) {
      var op = _ops.nth_data( i );
      if( op.get_completers( curpos, ref completers ) ) {
        return;
      }
    }
  }

  public override string to_string( string prefix ) {
    string[] str = {};
    _ops.foreach((op) => {
      str += op.to_string( prefix + "  " );
    });
    return( "%s\n%s%s".printf( "SUBEXP", (prefix + "  "), string.joinv( "\n%s".printf( prefix + "  " ), str ) ) );
  }

}

public class SearchCriteria {

  private SearchSubexp _subexp;

  public SearchCriteria() {
    _subexp = new SearchSubexp( 0 );
  }

  public void parse_search_text( string text ) {
    parse_search_text_helper( text, 0, ref _subexp );
  }

  private void parse_search_text_helper( string text, int spos, ref SearchSubexp subexp ) {

    string current_key  = "";
    string current_term = "";
    string subtext      = "";
    int    paren_count  = 0;
    bool   in_quote     = false;
    bool   colon_found  = false;
    int    last_spos    = spos;

    for( int i=0; i<text.length; i++ ) {
      if( in_quote ) {
        if( text[i] == '"' ) {
          in_quote = false;
          subexp.add_key_value( last_spos, true, ref current_key, ref current_term );
          last_spos = (spos + i + 1);
        } else {
          current_term += text[i].to_string();
        }
      } else if( paren_count > 0 ) {
        if( (text[i] == ')') && (--paren_count == 0) ) {
          var child = new SearchSubexp( last_spos );
          parse_search_text_helper( subtext, last_spos, ref child );
          subexp.add_subexp( child );
          subtext = "";
          last_spos = (spos + i + 1);
        } else {
          subtext += text[i].to_string();
        }
      } else if( text[i].isspace() ) {
        switch( current_term.down() ) {
          case "and" :  subexp.add_and( last_spos );  break;
          case "or"  :  subexp.add_or( last_spos );   break;
          default    :  subexp.add_key_value( last_spos, false, ref current_key, ref current_term );  break;
        }
        current_term = "";
        last_spos    = (spos + i + 1);
      } else {
        switch( text[i] ) {
          case '(' :
            subtext   = "";
            paren_count++;
            last_spos = (spos + i + 1);
            break;
          case '"' :
            in_quote  = true;
            last_spos = (spos + i + 1);
            break;
          case '&' :
            subexp.add_key_value( last_spos, false, ref current_key, ref current_term );
            subexp.add_and( spos + i );
            last_spos = (spos + i + 1);
            break;
          case '|' :
            subexp.add_key_value( last_spos, false, ref current_key, ref current_term );
            subexp.add_or( spos + i );
            last_spos = (spos + i + 1);
            break; 
          case '!' :
            subexp.add_key_value( last_spos, false, ref current_key, ref current_term );
            subexp.add_not( spos + i );
            last_spos = (spos + i + 1);
            break;
          case ':' :
            current_key  = current_term;
            current_term = "";
            break;
          default :
            current_term += text[i].to_string();
            break;
        }
      }
    }

    subexp.add_key_value( last_spos, in_quote, ref current_key, ref current_term );

  }

  public bool matches_rule( DirAction rule ) {
    return( _subexp.matches( rule ) );
  }

  public void get_completers( int curpos, ref SList<SearchCompletion> completers ) {
    _subexp.get_completers( curpos, ref completers );
  }

  public void print() {
    stdout.printf( "Criteria:\n%s\n", _subexp.to_string( "" ) );
  }

}
