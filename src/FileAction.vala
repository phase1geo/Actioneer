public class FileAction {

  public bool   err    { get; set; default = false; }
  public string errmsg { get; set; default = ""; }

  public FileAction() {}

  public virtual bool execute( string pathname ) {
    return( false );
  }

  public virtual Xml.Node* save() {
    return( null );
  }

  public virtual void load( Xml.Node* node ) {}

}
