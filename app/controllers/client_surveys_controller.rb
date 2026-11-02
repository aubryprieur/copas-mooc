# Indicateur 30 : avis du commanditaire, recueilli par un lien sécurisé (sans compte).
class ClientSurveysController < ApplicationController
  before_action :set_session

  def new
    return render :thanks if @session.client_survey

    @survey = @session.build_client_survey(respondent_name: @session.organization&.contact_name)
  end

  def create
    return redirect_to new_client_survey_path(token: @session.access_token) if @session.client_survey

    @survey = @session.build_client_survey(params.require(:client_survey).permit(:respondent_name, :overall_rating, :objectives_rating,
                                                                                 :organization_rating, :trainer_rating, :observed_effects, :comment))
    if @survey.save
      redirect_to new_client_survey_path(token: @session.access_token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_session
    @session = CourseSession.includes(:course, :organization).find_by!(access_token: params[:token])
    @course = @session.course
  end
end
