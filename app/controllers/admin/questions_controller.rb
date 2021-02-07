class Admin::QuestionsController < ApplicationController
 before_action :authenticate_admin!

 layout "admin"

 def show
  @question = Question.find(params[:id])
 end

 def index
  @questions = Question.all
 end

 def new
  @workshop = Workshop.find(params[:workshop_id])
  @question = Question.new
 end

 def edit
  @workshop = Workshop.find(params[:workshop_id])
  @question = Question.find(params[:id])
 end

 def update
  @question = Question.find(params[:id])
  if @question.update_attributes(admin_question_params)
   flash[:notice] = 'Changes updated successfully!'
   redirect_back(fallback_location: root_path)
  else
   flash[:notice] = 'Could not update, Please try again'
   render :edit, alert: "Could not update, Please try again"
  end
 end

 def create
  @workshop = Workshop.find(params[:workshop_id])
  @question = Question.new(admin_question_params)

  respond_to do |format|
   if @question.save
    format.html { redirect_to edit_admin_workshop_url(@workshop), notice: 'Question was successfully created.' }
    format.json { render json: @question, status: :created, location: [:admin,@question] }
   else
    format.html { render action: "new" }
    format.json { render json: @question.errors, status: :unprocessable_entity }
   end
  end
 end

 def destroy
  @workshop = Workshop.find(params[:workshop_id])
  @question = Question.find(params[:id])
  @Question.destroy
  redirect_to edit_admin_workshop_url(@workshop), notice: "Successfully deleted the question"
 end

 private

 def set_question
  @question = current_question
 end

 def admin_question_params
  params.require(:question).permit(:question, :answer, :distractor_1, :distractor_2, :distractor_3, :workshop_id)
 end

end
