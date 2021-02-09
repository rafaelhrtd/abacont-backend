class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  respond_to :json
  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  around_action :switch_locale

  def switch_locale(&action)
    locale = current_user.try(:language) || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, params)
  end

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: '400',
          title: 'Bad Request',
          detail: resource.errors,
          code: '100'
        }
      ]
    }, status: :bad_request
  end

  protected 

  def access_denied
    render json: {}, status: :forbidden
  end



  def record_not_found
    render json: {}, status: 404
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :token, :company_id, company_attributes: [:name]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:id, :email, :password, :password_confirmation, :current_password, :language])
  end
end
