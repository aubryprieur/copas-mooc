class AnswersController < ApplicationController
  before_action :authenticate_user!

  def index
    @questions = Question.all
    @answers = Answer.all

    @workshop = @questions[0].workshop_id
  end

  def new
    @question = Question.find(params[:question_id])
    @answer = Answer.new

    @questions = Question.all
  end

  def create
    @question = Question.find(params[:question_id])
    @workshop = @question.workshop_id
    @questions = Question.all
    limit = @questions.count
    @answer = Answer.new(answer_params)
    @answer.user_answer = params[:answer][:user_answer]
    @answer.question_id = params[:question_id]
    @answer.workshop_id = params[:workshop_id]
    @answer.user_id = current_user.id
    if @answer.save
      if @question.id < limit
        redirect_to new_question_answer_path(@question.id+1), notice: "Réponse enregistrée."
      else
        redirect_to workshop_results_path(@workshop), notice: "QCM terminé."
      end
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:user_answer, :user_id, :question_id, :workshop_id)
  end

end
