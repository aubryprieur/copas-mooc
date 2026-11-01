class SurveyMailer < ApplicationMailer
  def cold
    @enrollment = params[:enrollment]
    @course = @enrollment.course
    mail(to: @enrollment.user.email, subject: "Trois mois après : que retenez-vous de « #{@course.title} » ?")
  end
end
