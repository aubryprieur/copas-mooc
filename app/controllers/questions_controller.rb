class QuestionsController < ApplicationController
 before_action :authenticate_admin!, only: [:sort]
 before_action :authenticate_user!, only: [:show]

 def show
  @question = Question.find(params[:id])
 end

 def sort
  params[:question].each_with_index do |id, index|
   Question.where(id: id).update_all(order: index + 1)
  end
  head :ok
 end

 private

 def set_question
  @question = current_question
 end

 def question_params
  params.require(:question).permit(:question, :answer, :distractor_1, :distractor_2, :distractor_3, :workshop_id)
 end

end
