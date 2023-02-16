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

public class SearchOp {

  public SearchOpType op { get; private set; default = SearchOpType.NUM; }

  /* Default constructor */
  public SearchOp( SearchOpType op ) {
    this.op = op;
  }

  public virtual bool check_match( DirAction rule ) {
    return( true );
  }

  public virtual string to_string( string prefix ) {
    return( "%s".printf( op.to_string() ) );
  }

}

public class SearchOpAnd : SearchOp {
  public SearchOpAnd() {
    base( SearchOpType.AND );
  }
}

public class SearchOpOr : SearchOp {
  public SearchOpOr() {
    base( SearchOpType.OR );
  }
}

public class SearchOpNot : SearchOp {
  public SearchOpNot() {
    base( SearchOpType.NOT );
  }
}

public class SearchOpValue : SearchOp {
  private string _val;
  public SearchOpValue( string val ) {
    base( SearchOpType.VALUE );
    _val = val;
  }
  public bool matches( DirAction rule ) {
    for( int i=0; i<rule.conditions.size(); i++ ) {
      var cond = rule.conditions.get_condition( i );
      if( cond.matches( null, _val ) ) {
        return( true );
      }
    }
    for( int i=0; i<rule.actions.size(); i++ ) {
      var act = rule.actions.get_action( i );
      if( act.matches( _val ) ) {
        return( true );
      }
    }
    return( rule.name.contains( _val ) );
  }
  public override bool check_match( DirAction rule ) {
    return( matches( rule ) );
  }
  public override string to_string( string prefix ) {
    return( "%s (%s)".printf( op.to_string(), _val ) );
  }
}

public class SearchOpKeyValue : SearchOp {
  private ActionConditionType _cond_type;
  private FileActionType      _act_type;
  private string              _val;
  public SearchOpKeyValue( string key, string val ) {
    base( SearchOpType.KEY_VALUE );
    _cond_type = ActionConditionType.parse( key.down(), false );
    _act_type  = FileActionType.parse( key.down(), false );
    _val       = val;
  }
  public bool matches( DirAction rule ) {
    if( _cond_type != ActionConditionType.NUM ) {
      for( int i=0; i<rule.conditions.size(); i++ ) {
        var cond = rule.conditions.get_condition( i );
        if( cond.cond_type == _cond_type ) {
          return( cond.matches( _cond_type, _val ) );
        }
      }
    } else if( _act_type != FileActionType.NUM ) {
      for( int i=0; i<rule.actions.size(); i++ ) {
        var act = rule.actions.get_action( i );
        if( act.action_type == _act_type ) {
          return( act.matches( _val ) );
        }
      }
    } else {
      return( rule.name.contains( _val ) );
    }
    return( false );
  }
  public override bool check_match( DirAction rule ) {
    return( matches( rule ) );
  }
  public override string to_string( string prefix ) {
    return( "%s (c: %s, a: %s, v: %s)".printf(
        op.to_string(),
        ((_cond_type == ActionConditionType.NUM) ? "" : _cond_type.to_string()),
        ((_act_type  == FileActionType.NUM)      ? "" : _act_type.to_string()),
        _val
      )
    );
  }
}

public class SearchSubexp : SearchOp {

  private SList<SearchOp> _ops;

  public SearchSubexp() {
    base( SearchOpType.SUBEXP );
    _ops = new SList<SearchOp>();
  }

  public void add_and() {
    var op = new SearchOpAnd();
    _ops.append( op );
  }

  public void add_or() {
    var op = new SearchOpOr();
    _ops.append( op );
  }

  public void add_not() {
    var op = new SearchOpNot();
    _ops.append( op );
  }

  public void add_key_value( ref string key, ref string val ) {
    if( val != "" ) {
      SearchOp op;
      if( key != "" ) {
        op = new SearchOpKeyValue( key, val );
      } else {
        switch( val.down() ) {
          case "and" :  op = new SearchOpAnd();         break;
          case "or"  :  op = new SearchOpOr();          break;
          default    :  op = new SearchOpValue( val );  break;
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
    stdout.printf( "subexp matches result: %s\n", res.to_string() );
    return( res );
  }

  public override bool check_match( DirAction rule ) {
    return( matches( rule ) );
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
    _subexp = new SearchSubexp();
  }

  public void parse_search_text( string text ) {
    parse_search_text_helper( text, ref _subexp );
  }

  private void parse_search_text_helper( string text, ref SearchSubexp subexp ) {
    string current_key  = "";
    string current_term = "";
    string subtext      = "";
    int    paren_count  = 0;
    bool   in_quote     = false;
    bool   colon_found  = false;
    stdout.printf( "In parse_search_text_helper: %s\n", text );
    for( int i=0; i<text.length; i++ ) {
      if( in_quote ) {
        if( text[i] == '"' ) {
          in_quote = false;
          subexp.add_key_value( ref current_key, ref current_term );
        } else {
          current_term += text[i].to_string();
        }
      } else if( paren_count > 0 ) {
        if( (text[i] == ')') && (--paren_count == 0) ) {
          var child = new SearchSubexp();
          parse_search_text_helper( subtext, ref child );
          subexp.add_subexp( child );
          subtext = "";
        } else {
          subtext += text[i].to_string();
        }
      } else if( text[i].isspace() ) {
        switch( current_term.down() ) {
          case "and" :  subexp.add_and();  break;
          case "or"  :  subexp.add_or();   break;
          default    :  subexp.add_key_value( ref current_key, ref current_term );  break;
        }
        current_term = "";
      } else {
        switch( text[i] ) {
          case '(' :
            subtext = "";
            paren_count++;
            break;
          case '"' :
            in_quote = true;
            break;
          case '&' :
            subexp.add_key_value( ref current_key, ref current_term );
            subexp.add_and();
            break;
          case '|' :
            subexp.add_key_value( ref current_key, ref current_term );
            subexp.add_or();
            break; 
          case '!' :
            subexp.add_key_value( ref current_key, ref current_term );
            subexp.add_not();
            break;
          case ':' :
            current_key = current_term;
            current_term = "";
            break;
          default :
            current_term += text[i].to_string();
            break;
        }
      }
    }
    subexp.add_key_value( ref current_key, ref current_term );
  }

  public bool matches_rule( DirAction rule ) {
    return( _subexp.matches( rule ) );
  }

  public void print() {
    stdout.printf( "Criteria:\n%s\n", _subexp.to_string( "" ) );
  }

}
