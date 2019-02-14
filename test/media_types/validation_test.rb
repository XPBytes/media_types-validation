require "test_helper"

class MediaTypes::ValidationTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MediaTypes::Validation::VERSION
  end
end
