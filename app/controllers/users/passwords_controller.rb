class Users::PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      flash[:notice] = t("devise.passwords.send_instructions")
      redirect_to_with_js(after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_to do |format|
        format.html {
          respond_with(resource)
        }
        format.js
      end
    end
  end
end