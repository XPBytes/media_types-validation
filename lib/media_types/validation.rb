require "media_types/validation/version"

require 'oj'
require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module MediaTypes
  module Validation
    class Error < StandardError; end

    extend ActiveSupport::Concern

    mattr_accessor :json_invalid_media_proc, :raise_on_json_invalid_media

    def self.configure(&block)
      instance_exec self, &block
    end

    def validate_json_with_media_type(body, media_type:)
      return body unless media_type_json?(media_type: media_type)

      if raise_on_json_invalid_media
        json_valid_media_or_throw?(body, media_type: media_type)
      else
        json_valid_media?(body, media_type: media_type)
      end
    end

    private

    def media_type_json?(media_type:)
      String(media_type.suffix).to_sym == :json
    end

    def json_valid_media_or_throw?(body, media_type:)
      parse_body_as_json(body).tap do |parsed_body|
        media_type.validate!(parsed_body)
      end
    end

    def json_valid_media?(body, media_type:)
      json_valid_media_or_throw?(body, media_type: media_type)
    rescue ::MediaTypes::Scheme::ValidationError => err
      if json_invalid_media_proc.respond_to?(:call)
        instance_exec(media_type: media_type, err: err, body: body, &json_invalid_media_proc)
      else
        message = format(
          '[media type validation] The data being sent as %<media_type>s is invalid:' + "\n" \
        '%<err>s' + "\n" \
        'Parsed body: %<data>s',
          media_type: media_type,
          err: err,
          data: parse_body_as_json(body)
        )

        warn message
      end

      body
    end

    def parse_body_as_json(body)
      Oj.load(Oj.dump(body, mode: :compat), mode: :strict)
    end
  end
end
