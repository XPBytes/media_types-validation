# MediaTypes::Validation

[![Build Status: master](https://travis-ci.com/XPBytes/media_types-validation.svg)](https://travis-ci.com/XPBytes/media_types-validation)
[![Gem Version](https://badge.fury.io/rb/media_types-validation.svg)](https://badge.fury.io/rb/media_types-validation)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Authorize a certain block with cancan

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'media_types-validation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install media_types-validation

## Usage

I

```ruby
require 'media_types/validation'

class ApiController < ActionController::API
  include MediaTypes::Validation
  
  def render_json_media(media, status: :ok)
    # serialize_media is a fictional method that returns a serializer
    # -> serializer has .to_hash which returns the body as a hash
    # -> serializer has .current_media_type which returns the MediaType::Constructable for the current state
    serializer = serialize_media(media)
    render json: validate_json_with_media_type(serializer.to_hash, media_type: serializer.current_media_type),
         status: status,
         content_type: request.format.to_s
  end
end

class BookController < ApiController
  def show
    content = GenerateBookResponse.call(@book)
    render_json_media(content)
  end
end
```

### Configuration

In an initializer you can set procs in order to change the default behaviour:

```ruby
MediaTypes::Validation.configure do |this|
  this.json_invalid_media_proc = proc do |controller, media_type:, err:, body:| 
    controller.response['Warn'] = '199 media type %s is invalid (%s)' % [media_type, err]
    warn controller.response['Warn'] + "\n" + body
  end
  
  # Or alternatively you can always raise
  this.raise_on_json_invalid_media = true
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [XPBytes/media_types-validation](https://github.com/XPBytes/media_types-validation).
