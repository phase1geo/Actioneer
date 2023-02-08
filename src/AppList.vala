public class AppList {

  private static List<AppInfo> _apps = null;

  public static void initialize() {
    if( _apps == null ) {
      _apps = new List<AppInfo>();
      AppInfo.get_all().foreach((app) => {
        if( app.should_show() && app.supports_uris() ) {
          _apps.append( app );
        }
      });
      _apps.sort((a,b) => {
        return( strcmp( a.get_display_name(), b.get_display_name() ) );
      });
    }
  }

  public static int num_apps() {
    initialize();
    return( (int)_apps.length() );
  }

  public static int get_index( AppInfo info ) {
    initialize();
    return( _apps.index( info ) );
  }

  public static string get_app_name( int index ) {
    initialize();
    return( _apps.nth_data( index ).get_display_name() );
  }

  public static string get_app_id( int index ) {
    initialize();
    return( _apps.nth_data( index ).get_id() );
  }

  public static AppInfo? get_app( int index ) {
    initialize();
    return( _apps.nth_data( index ) );
  }

  public static AppInfo? get_app_with_id( string id ) {
    AppInfo? found = null;
    initialize();
    _apps.foreach((app) => {
      if( app.get_id() == id ) {
        found = app;
      }
    });
    return( found );
  }

}
