class Verification::ResidenceController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  skip_authorization_check

  def new
    @residence = Verification::Residence.new(user: current_user)
  end

  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    if @residence.save
      log_event("verification", "census")
      redirect_to verified_user_path, notice: t("verification.residence.create.flash.success")
    else
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service, :redeemable_code)
    end
end
