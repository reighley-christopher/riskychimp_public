var jQueryInterval;

(function(){
  loadjQuery();
  jQueryInterval = setInterval(checkjQuery, 100);
})();

function jQueryIsReady() {
  initialReport();
}

function checkjQuery() {
  if (typeof jQuery == "undefined") {
    return false;
  }
  else {
    clearTimeout(jQueryInterval);
    jQueryIsReady();
  }
}

function loadjQuery() {
  if (typeof jQuery == "undefined") {
    var jqueryScript = document.createElement('script');
    jqueryScript.type = "text/javascript";
    jqueryScript.src = ("//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js");
    var script = document.getElementsByTagName('script')[0];
    script.parentNode.insertBefore(jqueryScript, script);
  }
}

function getPlugins() {
  var plugin_str = "";
  for(var i=0; i < navigator.plugins.length; i++) {
    plugin = navigator.plugins[i];
    for(var j=0; j < plugin.length; j++) {
      plugin_str = plugin_str + plugin[j].description + plugin[j].suffixes + plugin[j].type;
    }
    plugin_str = plugin_str + plugin.name + plugin.description + plugin.filename;
  }
  return escape(plugin_str);
}

function getUtcOffsets() {
  var dec = new Date(2000, 12, 31);
  var june = new Date(2000, 6, 1);
  return dec.getTimezoneOffset().toString() + "," + june.getTimezoneOffset().toString();
}

function getCapabilities() {
  var tempArr = new Array();

  for (var name in navigator) {
    var value = navigator[name];

    switch (typeof(value)) {
      case "string":
      case "boolean":

        var tempStr = "navigator." + name + "=" + escape(value);
        tempArr.push(tempStr);
        break;
    }
  }

  for (var name in screen) {
    var value = screen[name];

    switch (typeof(value)) {
      case "number":
        var tempStr = "screen." + name + "=" + escape(value);
        tempArr.push(tempStr);
        break;
    }
  }
  return tempArr.join("&");
}

function initialReport() {
  var data = getJsonData();
  var src = getSource();

  var tmp = src.split("://");
  tmp = tmp[tmp.length - 1];
  var host = tmp.split("/")[0];
  host = "http://" + host + "/fingerprint/phonehome";

  ajaxRequest("POST", data, host, "fingerprintCallback");
}

function getSource() {
  var scripts = document.getElementsByTagName("script");
  var src;
  for(var i=0; i < scripts.length; i++) {
    if (scripts[i].src.indexOf("fingerprint.js") != -1) {
      src = scripts[i].src;
      break;
    }
  }
  return src;
}

function getJsonData() {
  return {"flash_capabilities": getCapabilities(), "utc_offsets": getUtcOffsets(), "plugins": getPlugins()};
}

function ajaxRequest(method, data, url, callBackAction) {
  $.ajax({
    type: method,
    url: url,
    data: data,
    success: function(data) {
      if (eval("typeof " + callBackAction) != "undefined") {
        window[callBackAction](data);
      }
    }
  });
}
