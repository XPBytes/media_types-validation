require "test_helper"

require 'media_types/dsl'

class MediaTypes::ValidationTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MediaTypes::Validation::VERSION
  end

  def with_captured_stderr
    original_stdout = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = original_stdout
  end

  class FakeController
    include ::MediaTypes::Validation

    def action(content, media_type)
      validate_json_with_media_type(content, media_type: media_type)
    end

    class CustomBoom < StandardError; end

    def boom(message)
      raise CustomBoom, message
    end
  end

  class QueryMediaType
    include MediaTypes::Dsl

    def self.base_format
      'application/vnd.mydomain.%<type>s.v%<version>.s%<view>s+%<suffix>s'
    end

    media_type 'query', defaults: { suffix: :json, version: 2 }

    validations do
      attribute :query do
        attribute :question, String
        attribute :answer, Numeric
      end
    end
  end

  def setup
    @controller = FakeController.new
  end

  def teardown
    ::MediaTypes::Validation.configure do
      self.json_invalid_media_proc = nil
      self.raise_on_json_invalid_media = false
    end
  end

  def test_validate_body_against_media_type
    content = {
      query: {
        question: 'what is the answer to ...',
        answer: 42
      }
    }

    warns = with_captured_stderr do
      @controller.action(content, QueryMediaType.to_constructable)
    end

    assert_empty warns
  end

  def test_validate_invalid_body_against_media_type
    content = {
      query: {
        question: 'what is the answer to ...'
      }
    }

    warns = with_captured_stderr do
      @controller.action(content, QueryMediaType.to_constructable)
    end

    refute_empty warns
    assert warns.include?('Missing keys in output')
  end

  def test_raise_on_error
    ::MediaTypes::Validation.configure do |configuration|
      configuration.raise_on_json_invalid_media = true
    end

    content = {
        query: {
            question: 'what is the answer to ...'
        }
    }

    assert_raises do
      @controller.action(content, QueryMediaType.to_constructable)
    end
  end

  def test_use_custom_warn_action
    ::MediaTypes::Validation.configure do
      self.json_invalid_media_proc = proc do |media_type:, err:, **_opts|
        boom('199 media type %s is invalid (%s)' % [media_type, err])
      end
    end

    assert_raises FakeController::CustomBoom do
      @controller.action({}, QueryMediaType.to_constructable)
    end
  end
end
