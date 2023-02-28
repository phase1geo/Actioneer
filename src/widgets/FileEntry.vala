using Gtk;

public class FileEntry : Entry {

  public class FileEntry() {

    can_focus                   = false;
    placeholder_text            = _( "Select a folder" );
    hexpand                     = true;
    hexpand_set                 = true;
    primary_icon_activatable    = true;
    primary_icon_name           = "document-open-symbolic";
    primary_icon_tooltip_text   = _( "Browse filesystem" );
    secondary_icon_activatable  = false;
    secondary_icon_name         = "";
    secondary_icon_tooltip_text = _( "Clear the directory" );

    icon_release.connect((pos, e) => {
      if( pos == EntryIconPosition.PRIMARY ) {
        open_file();
      } else {
        text = "";
        secondary_icon_activatable = false;
        secondary_icon_name        = "";
      }
    });

  }

  private void open_file() {
    var dialog = new FileChooserNative( _( "Choose Directory" ), Actioneer.appwin, FileChooserAction.SELECT_FOLDER,
                                        _( "Choose" ), _( "Cancel" ) );
    if( dialog.run() == ResponseType.ACCEPT ) {
      text = dialog.get_filename();
      secondary_icon_activatable = true;
      secondary_icon_name        = "edit-clear-symbolic";
    }
  }

}
