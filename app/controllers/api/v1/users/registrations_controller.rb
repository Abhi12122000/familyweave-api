# frozen_string_literal: true

class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  # Disable parameter wrapping for this controller specifically for JSON format
  wrap_parameters format: []

  respond_to :json

  # configure_sign_up_params prepend_before_action is kept, though its direct effect on
  # devise_parameter_sanitizer.sanitize(:sign_up) has been problematic.
  # The main logic for parameter sanitization will now be within the overridden sign_up_params.
  prepend_before_action :configure_sign_up_params, only: [:create]

  # Override the Devise create action to prevent automatic sign-in after registration
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      # User is created and persisted.
      # For an API, we directly call respond_with. expire_data_after_sign_in! might still be relevant if using features like :trackable.
      expire_data_after_sign_in! if resource.active_for_authentication? # Conditional call
      respond_with resource # Let respond_with handle the successful JSON response
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource # This calls our respond_with for errors
    end
  end

  private

  def respond_with(resource, opts = {}) # opts is kept for compatibility but not strictly used for location anymore
    if resource.persisted? && resource.errors.empty? # Clearer success condition
      render json: {
        status: { code: 201, message: 'Signed up successfully. Please log in to obtain a token.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :created
    elsif resource.errors.any?
      Rails.logger.info "[INFO] User registration failed. Resource attributes: #{resource.attributes.inspect}"
      Rails.logger.info "[INFO] Validation errors: #{resource.errors.full_messages.inspect}"
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.join(', ')}" },
        errors: resource.errors.to_hash
      }, status: :unprocessable_entity
    else
      # This case should ideally not be reached if logic in create is correct.
      Rails.logger.error "[ERROR] respond_with called in an unexpected state. Resource: #{resource.inspect}, opts: #{opts.inspect}"
      render json: { status: { message: "An unexpected server error occurred during registration."}}, status: :internal_server_error
    end
  end

  # It's good practice to explicitly permit parameters for Devise controllers
  # def create
  #   Rails.logger.debug "[DEBUG] In overridden create. sign_up_params: #{sign_up_params.inspect}"
  #   super
  # end

  protected

  # This method is called by Devise to get the parameters for creating a new user.
  # We override it to directly use Rails strong parameters to construct the hash of permitted attributes.
  def sign_up_params
    permitted_params = params.require(:user).permit(:username, :first_name, :last_name, :email, :password, :password_confirmation)
    Rails.logger.debug "[DEBUG] RegistrationsController#sign_up_params: Permitted parameters: #{permitted_params.inspect}"
    if permitted_params.empty? && params[:user].present?
        Rails.logger.warn "[WARN] RegistrationsController#sign_up_params: Permitted params are empty, but raw params[:user] were present: #{params[:user].inspect}. Review permit keys or request structure."
    end
    permitted_params
  rescue ActionController::ParameterMissing => e
    Rails.logger.error "[ERROR] RegistrationsController#sign_up_params: ParameterMissing - #{e.message}"
    {}
  end

  # This method is still called via prepend_before_action.
  # Its call to devise_parameter_sanitizer.permit might be redundant for populating sign_up_params now,
  # but it doesn't hurt and aligns with Devise's expected structure.
  def configure_sign_up_params
    Rails.logger.debug "[DEBUG] RegistrationsController#configure_sign_up_params: Configuring devise_parameter_sanitizer for :sign_up."
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :email, :password, :password_confirmation])
    Rails.logger.debug "[DEBUG] RegistrationsController#configure_sign_up_params: Finished configuring."
  end
end 