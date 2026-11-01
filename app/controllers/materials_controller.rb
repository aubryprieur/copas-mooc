# Supports d'une session sur site : réservés aux participants, pendant 1 an après la fin de la session.
class MaterialsController < ApplicationController
  include LearnerEnrollment
  before_action :set_enrollment

  def show
    authorize @enrollment, :owner?
    session = @enrollment.course_session
    raise ActiveRecord::RecordNotFound unless session

    unless session.materials_available?
      return redirect_to enrollment_path(@enrollment), alert: "Les supports de cette session ne sont plus disponibles (accès d'un an après la formation)."
    end

    file = session.materials.find(params[:attachment_id])
    @enrollment.log!("material.downloaded", subject: session, metadata: { filename: file.filename.to_s })
    redirect_to rails_blob_path(file, disposition: "attachment", expires_in: 10.minutes), allow_other_host: false
  end
end
