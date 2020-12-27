class MigrateBodytoRichBodyWorkshops < ActiveRecord::Migration[6.0]
  def up
    Workshop.find_each do |workshop|
      workshop.update(rich_body: workshop.description)
    end
  end
end
