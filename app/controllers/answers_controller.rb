class AnswersController < ApplicationController

  def index
    @questions = Question.all
    @answers = Answer.all
  end

  def show
    @answer = Answer.find(params[:id])
  end

  def new
    @question = Question.find(params[:question_id])
    @answer = Answer.new
  end

  def create
    @question = Question.find(params[:question_id])
    @questions = Question.all
    limit = @questions.count
    @answer = Answer.new(answer_params)
    @answer.user_answer = params[:answer][:user_answer]
    @answer.question_id = params[:question_id]
    @answer.user_id = current_user.id
    if @answer.save
      if @question.id < limit
        redirect_to new_question_answer_path(@question.id+1), notice: "Réponse enregistrée."
      else
        redirect_to question_answers_path, notice: "QCM terminé."
      end
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:user_answer, :user_id, :question_id)
  end

end
