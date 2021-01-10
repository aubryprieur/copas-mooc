class ResultsController < ApplicationController
  def results
    @questions = Question.all
    @answers = Answer.all

    @workshop = @questions[0].workshop_id
  end
end
