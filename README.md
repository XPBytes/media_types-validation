# MediaTypes::Validation

[![Build Status: master](https://travis-ci.com/XPBytes/media_types-validation.svg)](https://travis-ci.com/XPBytes/media_types-validation)
[![Gem Version](https://badge.fury.io/rb/media_types-validation.svg)](https://badge.fury.io/rb/media_types-validation)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Add controller time validation for [media types](https://github.com/SleeplessByte/media_types-ruby) and react accordingly.

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

If you add the `MediaTypes::Validation` controller concern, `validate_json_with_media_type` becomes available during
actions. This does _not_ validate only `JSON` output, but stringifies and then parses the body as `JSON`, so the 
limitations of `JSON` apply. This step is necessary in order to make sure `rails` types and others are first correctly
casted (and formatted).

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

By default, this method only outputs to `stderr` when something is wrong; see configuration below if you want to assign
your own behaviour, such as adding a `Warn` header, or raising a server error.

### Configuration

In an initializer you can set procs in order to change the default behaviour:

```ruby
MediaTypes::Validation.configure do
  self.json_invalid_media_proc = proc do |media_type:, err:, body:| 
    response['Warn'] = '199 media type %s is invalid (%s)' % [media_type, err]
    warn response['Warn'] + "\n" + body
  end
  
  # Or alternatively you can always raise
  self.raise_on_json_invalid_media = true
end
```

### Related

- [`MediaTypes`](https://github.com/SleeplessByte/media-types-ruby): :gem: Library to create media type definitions, schemes and validations
- [`MediaTypes::Deserialization`](https://github.com/XPBytes/media_types-deserialization): :cyclone: Add media types supported deserialization using your favourite parser, and media type validation.
- [`MediaTypes::Serialization`](https://github.com/XPBytes/media_types-serialization): :cyclone: Add media types supported serialization using your favourite serializer

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [XPBytes/media_types-validation](https://github.com/XPBytes/media_types-validation).
