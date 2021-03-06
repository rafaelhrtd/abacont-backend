# frozen_string_literal: true

class User::SessionsController < Devise::SessionsController
  respond_to :json

  def user_info
    if current_user == nil 
      render json: {}, status: 401
    else 
      render json: {
        user: current_user,
        companies: current_user.companies,
        company: current_user.company
      }
    end
  end

  private

  def respond_with(resource, _opts = {})
    render json: {user: resource, companies: resource.companies, company: resource.company}
  end

  def respond_to_on_destroy
    head :no_content
  end

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
