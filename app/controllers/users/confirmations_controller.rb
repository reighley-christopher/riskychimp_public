class Users::ConfirmationsController < Devise::ConfirmationsController
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    if successfully_sent?(resource)
      redirect_to_with_js(after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_to do |format|
        format.html {
          respond_with(resource)
        }
        format.js
      end
    end
  end

  protected

  def after_resending_confirmation_instructions_path_for(resource_name)
    flash[:notice] = t("devise.confirmations.resend_instructions") if signed_in?
    root_path
  end
end