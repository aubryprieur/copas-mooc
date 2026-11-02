class EnrollmentsController < ApplicationController
  include LearnerEnrollment
  before_action :set_enrollment

  # Vue « parcours » : étapes, modules, évaluations, attestation
  def show
    authorize @enrollment, :owner?
    if @enrollment.onboarding? && @enrollment.onsite? && @enrollment.needs_assessment.nil?
      redirect_to new_enrollment_needs_assessment_path(@enrollment)
    elsif @enrollment.onboarding? && !@enrollment.welcome_acknowledged_at
      redirect_to welcome_enrollment_path(@enrollment)
    end
  end

  # Indicateur 9 : livret d'accueil, règlement intérieur, assistance, référents
  def welcome
    authorize @enrollment, :owner?
    if @enrollment.onboarding? && @enrollment.onsite? && @enrollment.needs_assessment.nil?
      return redirect_to new_enrollment_needs_assessment_path(@enrollment)
    end
    @welcome = Page.fetch("livret-accueil")
  end

  def acknowledge_welcome
    authorize @enrollment, :onboard?
    if params[:confirm] == "1"
      @enrollment.acknowledge_welcome!
      if @enrollment.reload.onboarding? && @course.positioning_assessment && !@enrollment.positioning_done?
        redirect_to enrollment_assessment_path(@enrollment, @course.positioning_assessment),
                    notice: "Merci. Étape suivante : le positionnement d'entrée."
      else
        redirect_to enrollment_path(@enrollment), notice: "Merci, votre lecture est enregistrée."
      end
    else
      redirect_to welcome_enrollment_path(@enrollment), alert: "Cochez la case pour confirmer votre lecture."
    end
  end

  # Attestation de fin de formation (art. L6353-1)
  def certificate
    authorize @enrollment, :certificate?
    unless @enrollment.certificate_ready?
      return redirect_to enrollment_path(@enrollment), alert: "L'attestation sera disponible après la clôture de la dernière demi-journée."
    end
    pdf = CertificatePdf.new(@enrollment).render
    send_data pdf, filename: "attestation-#{@enrollment.certificate_number}.pdf", type: "application/pdf", disposition: "inline"
  end
end
