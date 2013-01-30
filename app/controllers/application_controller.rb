class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_mailer_host

  def redirect_to_with_js(dest_path)
    respond_to do |format|
      format.html {
        redirect_to dest_path
      }
      format.js {
        render js: "window.location.pathname='#{dest_path}'"
      }
    end
  end

  def admin_required
    unless current_user && current_user.has_role?(:admin)
      redirect_to refinery.root_path, notice: t("users.access.denied")
    end
  end

  protected
  def current_page(param_name = :page)
    [params[param_name].to_i, 1].max
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
