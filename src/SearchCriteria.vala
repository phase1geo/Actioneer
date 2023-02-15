public enum SearchOpType {
  AND,
  OR,
  NOT,
  VALUE,
  KEY_VALUE,
  SUBEXP,
  NUM
}

public class SearchOp {

  public SearchOpType op { get; private set; default = SearchOpType.NUM; }

  /* Default constructor */
  public SearchOp( SearchOpType op ) {
    this.op = op;
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
}

public class SearchOpKeyValue : SearchOp {
  private ActionConditionType _cond_type;
  private FileActionType      _act_type;
  private string              _val;
  public SearchOpKeyValue( string key, string val ) {
    base( SearchOpType.KEY_VALUE );
    _cond_type = ActionConditionType.parse( key, false );
    _act_type  = FileActionType.parse( key, false );
    _val       = val;
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
    return( false );
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
            subtext += text[i].to_string();
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
  }

  public bool matches_rule( DirAction rule ) {
    return( _subexp.matches( rule ) );
  }

}
