require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "une fiche incomplète ne peut pas être publiée (ind. 1)" do
    course = Course.new(title: "Fiche incomplète", status: :published)
    assert_not course.valid?
    assert_match(/indicateur 1/, course.errors[:base].join)
  end

  test "la date de mise à jour de la fiche suit les modifications" do
    course = create_course
    course.update_column(:info_updated_at, 1.year.ago)
    course.update!(prerequisites: "Connaître le parc social.")
    assert_in_delta Time.current, course.info_updated_at, 5
  end

  test "les indicateurs exposent leur formule de calcul (ind. 2)" do
    course = create_course
    assert course.results_indicators.effectif.formula.present?
  end
end
