using Gtk;

public class RuleStack : Stack {

  private RuleForm _form;

  public RuleForm form {
    get {
      return( _form );
    }
  }

  /* Default constructor */
  public RuleStack( MainWindow win ) {

    /* Create first welcome page */
    var welcome1 = new Granite.Widgets.Welcome( _( "Welcome to Actioneer" ), _( "Automate actions on your files!" ) );
    welcome1.append( "folder-open", _( "Add a directory to monitor" ), _( "Or click on the plus (+) button in the Directories panel" ) );
    welcome1.activated.connect((index) => {
      switch( index ) {
        case 0  :  win.dir_list.action_add();  break;
        default :  assert_not_reached();
      }
    });

    /* Create the second welcome page */
    var welcome2 = new Granite.Widgets.Welcome( _( "Nicely Done!" ), "" );
    welcome2.append( "folder-open", _( "Add another directory to monitor" ), _( "Or click on the plus (+) button in the Directories panel" ) );
    welcome2.append( "system-run", _( "Add a rule for the currently selected directory" ), _( "Or click on the plus (+) button in the Rules panel" ) );
    welcome2.activated.connect((index) => {
      switch( index ) {
        case 0  :  win.dir_list.action_add();  break;
        case 1  :  win.rule_list.action_add();  break;
        default :  assert_not_reached();
      }
    });

    _form = new RuleForm( win );

    /* Add the elements to the stack */
    transition_type = StackTransitionType.NONE;
    add_named( welcome1, "welcome1" );
    add_named( welcome2, "welcome2" );
    add_named( _form,    "form" );

  }

}
