class AppSettingsController < ApplicationController
  before_filter :admin_required
   # GET /app_settings/1/edit
  def edit
    @app_setting = AppSetting.find(params[:id])
  end


  # PUT /app_settings/1
  # PUT /app_settings/1.json
  def update
    @app_setting = AppSetting.find(params[:id])

    respond_to do |format|
      if @app_setting.update_attributes(params[:app_setting])
        format.html { redirect_to current_user, notice: 'Sender email was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app_setting.errors, status: :unprocessable_entity }
      end
    end
  end
end
