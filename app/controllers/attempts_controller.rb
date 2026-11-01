class AttemptsController < AssessmentsController
  def create
    previous = @enrollment.latest_attempt(@assessment)
    if previous && !@assessment.retakable?
      return redirect_to enrollment_assessment_attempt_path(@enrollment, @assessment, previous),
                         alert: "Vous avez déjà rendu cette évaluation."
    end

    answers = params.fetch(:answers, {}).permit(*@assessment.questions.ids.map(&:to_s)).to_h
    if answers.size < @assessment.questions.count
      @questions = @assessment.questions.includes(:choices)
      @answers = answers
      flash.now[:alert] = "Répondez à toutes les questions avant de valider."
      return render "assessments/show", status: :unprocessable_entity
    end

    attempt = @enrollment.attempts.create!(assessment: @assessment).grade!(answers)
    @enrollment.touch_activity!
    @enrollment.decide_positioning!(attempt) if @assessment.positioning? && @enrollment.positioning_decision.nil?
    @enrollment.complete!(attempt) if @assessment.final?

    redirect_to enrollment_assessment_attempt_path(@enrollment, @assessment, attempt)
  end

  def show
    @attempt = @enrollment.attempts.submitted.where(assessment: @assessment).find(params[:id])
    @answers = @attempt.attempt_answers.includes(:choice, question: %i[choices objective])
  end
end
