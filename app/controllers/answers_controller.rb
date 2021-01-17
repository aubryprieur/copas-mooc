class AnswersController < ApplicationController
  before_action :authenticate_user!

  def new
    @question = Question.find(params[:question_id])
    @workshop = @question.workshop_id
    @answer = Answer.new

    @questions = Question.where(workshop_id: @workshop)
  end

  def create
    @question = Question.find(params[:question_id])
    @workshop = @question.workshop_id
    @questions = Question.where(workshop_id: @workshop)
    @answers = Answer.where(workshop_id: @workshop, user_id: current_user)
    limit = @questions.count

    @answer = Answer.new(answer_params)
    @answer.user_answer = params[:answer][:user_answer]
    @answer.question_id = params[:question_id]
    @answer.workshop_id = params[:workshop_id]
    @answer.user_id = current_user.id
    if @answer.invalid?
      redirect_to workshop_results_path(@workshop), alert: "Vous avez déjà répondu au QCM."
    elsif @answer.save
      if @answers.count < limit
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
