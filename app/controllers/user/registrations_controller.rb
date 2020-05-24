# frozen_string_literal: true

class User::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create

    invite = UserInvite.where(token: sign_up_params[:token]).first if sign_up_params[:token] != nil
    sign_up_params[:company_id] = invite.company_id  if sign_up_params[:token] != nil
    render json: {errors: [invite: "does not exist"]} if sign_up_params[:token] != nil && invite == nil

    if invite != nil 
      build_resource(sign_up_params)
      resource.company = invite.company
    else 
      build_resource(sign_up_params)
    end

    resource.save
    print (resource.errors.full_messages)
    print (sign_up_params)
    yield resource if block_given?
    if resource.persisted?
      tag = nil
      if sign_up_params[:token] != nil
        tag = CompanyTagging.create_from_invite(invite: invite, user: resource)
        resource.switch_company(company: tag.company)
        invite.destroy
      else 
        tag = CompanyTagging.create({company: resource.company,
          user: resource, 
          role: "owner",
          can_write: true,
          can_read: true,
          can_invite: true,
          can_edit: true})
      end

      resource.switch_company(company: tag.company) 

      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        render json: {user: resource, companies: resource.companies, company: resource.company}
      else
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: {errors: resource.errors}
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
