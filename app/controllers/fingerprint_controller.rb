FINGERPRINT_COOKIE_KEY = 'riskybiz_fingerprint_cookie'

class FingerprintController < ApplicationController

  def download
    browser_id = request.cookies[FINGERPRINT_COOKIE_KEY]
    @browser = Browser.find_by_id(browser_id) if browser_id
    @browser = Browser.create unless @browser
    cookies[FINGERPRINT_COOKIE_KEY] = @browser.id
    if params[:format] == 'js'
      send_file 'app/assets/fingerprint/fingerprint.js',
                type: 'text/javascript',
                disposition: "inline", url_based_filename: true
    else
      send_file 'app/assets/flash/fingerprint.swf',
                type: 'application/x-shockwave-flash',
                disposition: "inline", url_based_filename: true
    end
  end

  def phonehome
    browser_id = request.cookies[FINGERPRINT_COOKIE_KEY]
    @cookieless = true unless browser_id
    @browser = Browser.find_by_id(browser_id) if browser_id
    @browser = Browser.create unless @browser
    cookies[FINGERPRINT_COOKIE_KEY] = @browser.id
    begin
      hash = JSON.parse(request.body.string)
    rescue
      hash = {}
    end
    hash["user_agent"] = request.headers["HTTP_USER_AGENT"]
    hash["http_accept_header"] =
    ["HTTP_ACCEPT", "HTTP_ACCEPT_ENCODING",
     "HTTP_ACCEPT_LANGUAGE", "HTTP_ACCEPT_CHARSET"].map do |hdr|
      request.headers[hdr]
    end.join("\n")
    hexdigest = Thumbprint.generate(hash)
    render json: %Q{\{"fingerprint":"#{hexdigest}"\}}
  end
end
