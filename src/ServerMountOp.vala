public class ServerMountOp : GLib.MountOperation {

  public ServerMountOpt() {
    base();
  }

  public override signal void ask_password( string message, string default_user, string default_domain, AskPasswordFlags flags );
Emitted when a mount operation asks the user for a password.
public virtual signal void ask_question (string message, string[] choices)
Emitted when asking the user a question and gives a list of choices for the user to choose from.
public virtual signal void reply (MountOperationResult result)
Emitted when the user has replied to the mount operation.

}
