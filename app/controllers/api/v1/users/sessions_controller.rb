# frozen_string_literal: true

class Api::V1::Users::SessionsController < Devise::SessionsController
  # Disable parameter wrapping for this controller specifically for JSON format
  wrap_parameters format: []

  respond_to :json

  prepend_before_action :configure_sign_in_params, only: [:create]

  def create
    Rails.logger.debug "[DEBUG] SessionsController#create: Attempting to authenticate."
    current_auth_options = auth_options # Capture original auth_options
    Rails.logger.debug "[DEBUG] SessionsController#create: Original auth_options: #{current_auth_options.inspect}"
    
    extracted_credentials = sign_in_params 
    Rails.logger.debug "[DEBUG] SessionsController#create: Credentials from sign_in_params: #{extracted_credentials.inspect}"

    if extracted_credentials[:email].blank? || extracted_credentials[:password].blank?
      Rails.logger.warn "[WARN] SessionsController#create: Email or password blank after sign_in_params processing."
      failed_resource = User.new(email: extracted_credentials[:email])
      failed_resource.errors.add(:base, I18n.t('devise.failure.invalid', authentication_keys: User.authentication_keys.join(', ')))
      return respond_with failed_resource, status: :unauthorized
    end

    # --- BEGIN MANUAL CHECK (as before, for verification) ---
    auth_key_manual = User.authentication_keys.first
    auth_value_manual = extracted_credentials[auth_key_manual]
    password_manual = extracted_credentials[:password]
    Rails.logger.debug "[DEBUG] Manual Check: auth_key=#{auth_key_manual}, auth_value=#{auth_value_manual}, password_present=#{password_manual.present?}"
    if auth_value_manual.present?
      temp_user_for_check = User.find_by(auth_key_manual => auth_value_manual)
      if temp_user_for_check
        Rails.logger.debug "[DEBUG] Manual Check: Found user by auth_key. Is password valid? #{temp_user_for_check.valid_password?(password_manual)}"
      else
        Rails.logger.debug "[DEBUG] Manual Check: User NOT found by auth_key: #{auth_value_manual}"
      end
    end
    # --- END MANUAL CHECK ---

    # --- BEGIN DIRECT AUTHENTICATION LOGIC ---
    # Attempt to find the user by email (re-using logic from manual check)
    auth_key = User.authentication_keys.first
    auth_value = extracted_credentials[auth_key]
    user_for_sign_in = auth_value.present? ? User.find_by(auth_key => auth_value) : nil

    if user_for_sign_in && user_for_sign_in.valid_password?(extracted_credentials[:password])
      # User authenticated successfully through manual check
      self.resource = user_for_sign_in # Set self.resource for Devise compatibility
      sign_in(resource_name, resource, store: false) # Tell Devise not to store in session for API
      Rails.logger.debug "[DEBUG] SessionsController#create: Manual authentication successful for user: #{resource.email}"
      yield resource if block_given?
      respond_with resource # This should then dispatch the JWT via the response header
    else
      # Manual authentication failed or warden failed previously
      Rails.logger.warn "[WARN] SessionsController#create: Manual authentication failed or user not found."
      # Mimic Warden's failure to provide a consistent response using devise.failure.invalid
      failed_resource = User.new(email: extracted_credentials[:email])
      error_message = I18n.t('devise.failure.invalid', authentication_keys: User.authentication_keys.join(', '))
      failed_resource.errors.add(:base, error_message)
      respond_with failed_resource, status: :unauthorized
    end
    # --- END DIRECT AUTHENTICATION LOGIC ---

  # Removing specific rescue for Warden::MissingStrategy due to NameError
  # The generic rescue below will catch other errors.
  rescue => e 
    Rails.logger.error "[ERROR] SessionsController#create: Unexpected error: #{e.message} \n#{e.backtrace.join("\n")}"
    render json: { status: { code: 500, message: "An unexpected error occurred during sign in." }}, status: :internal_server_error
  end

  private

  def respond_with(resource, opts = {})
    if resource.persisted? && resource.errors.empty? 
      Rails.logger.debug "[DEBUG] SessionsController#respond_with: Sign in successful for #{resource.email}. Token will be in header."
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      Rails.logger.info "[INFO] SessionsController#respond_with: Sign in failed. Errors: #{resource.errors.full_messages.join(', ')}"
      error_message = resource.errors.full_messages.join(', ').presence || "Invalid credentials or authentication failed."
      render json: {
        status: { code: 401, message: "Couldn't log in. #{error_message}" }
      }, status: opts[:status] || :unauthorized
    end
  end

  def respond_to_on_destroy # Sign out
    auth_header = request.headers['Authorization']
    unless auth_header && auth_header.match(/^Bearer\s+(.+)$/i)
      Rails.logger.warn "[WARN] SessionsController#respond_to_on_destroy: Attempted to sign out with invalid/missing Authorization header."
      return render json: { status: { code: 400, message: "Missing or malformed Authorization header." }}, status: :bad_request
    end
    jwt_token = auth_header.match(/^Bearer\s+(.+)$/i)[1]

    begin
      jwt_payload = JWT.decode(jwt_token, Rails.application.credentials.secret_key_base).first
      current_user = User.find_by(id: jwt_payload['sub'])
      if current_user
        Rails.logger.debug "[DEBUG] SessionsController#respond_to_on_destroy: Signing out user #{current_user.email}"
        sign_out(current_user)
        render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
      else
        Rails.logger.warn "[WARN] SessionsController#respond_to_on_destroy: No current user found from JWT (sub: #{jwt_payload.try(:[], 'sub')}) to sign out."
        render json: { status: 401, message: "Couldn't find an active session or user not found." }, status: :unauthorized
      end
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
      Rails.logger.warn "[WARN] SessionsController#respond_to_on_destroy: JWT error - #{e.message}"
      render json: { status: 401, message: "Invalid or expired token." }, status: :unauthorized
    end
  end

  protected

  def sign_in_params
    Rails.logger.debug "[DEBUG] SessionsController#sign_in_params: Raw params[:user]: #{params[:user].inspect}"
    permitted = params.require(:user).permit(:email, :password, :remember_me)
    Rails.logger.debug "[DEBUG] SessionsController#sign_in_params: Permitted: #{permitted.inspect}"
    permitted
  rescue ActionController::ParameterMissing => e
    Rails.logger.error "[ERROR] SessionsController#sign_in_params: ParameterMissing - #{e.message}. Params were: #{params.inspect}"
    {}
  end

  def configure_sign_in_params
    Rails.logger.debug "[DEBUG] SessionsController#configure_sign_in_params: Permitting keys for :sign_in (using resource_name: #{resource_name})."
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :remember_me])
    Rails.logger.debug "[DEBUG] SessionsController#configure_sign_in_params: Finished permitting keys."
  end
end 