#if !defined CEFSAMP_INC_
#define CEFSAMP_INC_
enum CEF_ValueType { CEF_STRING, CEF_INTEGER, CEF_FLOAT };
#define CEFSTR(%0) CEF_STRING, %0
#define CEFINT(%0) CEF_INTEGER, %0
#define CEFFLOAT(%0) CEF_FLOAT, %0
#define CEF_DEFAULT_MAX_DIST 50.0
#define CEF_DEFAULT_REF_DIST 15.0
native cef_create_browser(player_id, browser_id, const url[], bool:hidden, bool:focused);
native cef_destroy_browser(player_id, browser_id);
native cef_on_player_connect(player_id, const ip[]);
#endif
