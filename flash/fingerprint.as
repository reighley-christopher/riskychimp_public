package {
  import mx.core.Application;
  import mx.resources.ResourceManager;
  import flash.display.Sprite;
  import flash.external.ExternalInterface;
  import flash.net.URLRequest;
  import flash.net.URLLoader;
  import flash.text.Font;
  import flash.system.Capabilities;
  import flash.events.Event;
  import flash.utils.ByteArray;

  import mx.events.FlexEvent;

  import flash.net.LocalConnection;

  public class fingerprint extends Sprite {


    private const horrible_script:String = "(function() {var ret=\"\"; var i; for(i=0; i<navigator.plugins.length; i++){var p=navigator.plugins[i]; var j; for(j = 0; j<p.length; j++){ret = ret+p[j].description+p[j].suffixes+p[j].type}; ret = ret+p.name+p.description+p.filename}; return ret;})()";
    public var errorMessage:String;
    public var loader:URLLoader;
    public var js:Object;
    public var plugins:String = "no value";

    public function fingerprint() {
      flash.system.Security.allowDomain("*");
      appInit();
    }

    public function appInit():void {
      var onload:String = "";

	    if  (ExternalInterface.available) {
		    try {
		      ExternalInterface.addCallback("respond", respond);
		      ExternalInterface.addCallback("data", data);
		      ExternalInterface.addCallback("get_json", get_json);
		      ExternalInterface.addCallback("get_error", get_error);
		      ExternalInterface.addCallback("fingerprint", get_fingerprint);
		      ExternalInterface.addCallback("get_plugins", get_plugins);
		      plugins = ExternalInterface.call("eval", horrible_script);
          initial_report();
	      } catch(ex:Error) {
          errorMessage = ex.message;
        }
      }
    }

    public function respond():String {
	    try { return "RESPONSIVE"; }
	    catch(ex:Error) { errorMessage = ex.message; }
	    return "<<there was some kind of horrible error in respond()>>";
    }

    public function get_plugins():String {
      return plugins;
    }

    public function initial_report():void {
      try {
      var conn:LocalConnection = new LocalConnection();
      var connname:String = conn.domain;
      var loadUrl:String = loaderInfo.loaderURL.replace(/\/[^\/]*$/, "/phonehome");
      var request:URLRequest = new URLRequest(loadUrl);
      request.method = "POST";
      request.data = get_json();
      loader = new URLLoader();
      loader.addEventListener("complete", dataReady);
      loader.load(request);
      } catch(ex:Error) {
        errorMessage = ex.message;
      }
    }

    public function get_json():String {
    try {
      var str:String = JSON.stringify({"flash_capabilities":capabilities(), "fonts":fonts(), "utc_offsets":utc_offsets(), "plugins":get_plugins() });
      str = JSON.stringify({"flash_capabilities":capabilities(), "fonts":fonts(), "utc_offsets":utc_offsets(), "plugiins":get_plugins()});
      str = JSON.stringify({"plugins":get_plugins()});
      return str
    } catch(ex:Error) {
      errorMessage = ex.message;
      return "{\"error\":\""+ex.message+"\"}";
    }
    return "";
    }

    public function dataReady(evt:Event):void {
      var fun:String = loaderInfo.parameters["onload"];
      ExternalInterface.call(fun);
    }

    public function data():String {
      return loader.data;
    }

    public function fonts():String {
      var font_string:String = "";
      try {
      var font_enum:Array = Font.enumerateFonts(true);
      for(var fa:String in font_enum) { font_string = font_string + font_enum[fa].fontName; }
      } catch(ex:Error) {
        errorMessage = ex.message;
      }
      return font_string;
    }

    public function capabilities():String {
      try {
      return Capabilities.serverString;
      } catch(ex:Error) {
        errorMessage = ex.message;
      }
      return "";
    }

    public function get_fingerprint():String {
      return JSON.parse(loader.data).fingerprint;
    }

    public function get_error():String {
      return errorMessage;
    }

    public function utc_offsets():String {
      var december:Date = new Date(2000, 12, 21);
      var june:Date = new Date(2000, 6, 21);
      return december.getTimezoneOffset().toString() + ',' + june.getTimezoneOffset().toString();
    }
  }
}
