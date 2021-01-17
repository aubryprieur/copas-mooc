class ResultsController < ApplicationController
  def results
    @questions = Question.all
    @workshop = @questions[0].workshop_id
    @answers = Answer.where(user_id: current_user, workshop_id: @workshop)
  end
end
