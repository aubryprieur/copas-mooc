# Indicateur 30 : questionnaires à chaud (fin de parcours) et à froid (environ 3 mois après)
class SurveysController < ApplicationController
  include LearnerEnrollment
  before_action :set_enrollment
  before_action :set_kind

  def new
    authorize @enrollment, :owner?
    existing = @enrollment.survey_responses.find_by(kind: @kind)
    return redirect_to enrollment_path(@enrollment), notice: "Vous avez déjà répondu à ce questionnaire. Merci !" if existing

    @survey = @enrollment.survey_responses.new(kind: @kind)
  end

  def create
    authorize @enrollment, :owner?
    @survey = @enrollment.survey_responses.new(survey_params.merge(kind: @kind))
    if @survey.save
      redirect_to enrollment_path(@enrollment), notice: "Merci pour votre retour : il nous aide à améliorer la formation."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_kind
    @kind = params[:kind] == "cold" || params.dig(:survey_response, :kind) == "cold" ? "cold" : "hot"
    redirect_to enrollment_path(@enrollment) unless @enrollment.completed?
  end

  def survey_params
    params.require(:survey_response).permit(:overall_rating, :content_rating, :support_rating, :platform_rating,
                                            :objectives_rating, :recommend_score, :applied_in_practice, :comment)
  end
end
