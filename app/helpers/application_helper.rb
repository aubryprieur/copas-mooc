module ApplicationHelper
  def active_lesson(link_path)
    request.fullpath == link_path ? "active" : ""
  end
end
