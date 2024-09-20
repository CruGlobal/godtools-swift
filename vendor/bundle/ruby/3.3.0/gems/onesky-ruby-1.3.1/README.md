# OneSky - Ruby client

[![Build Status](https://travis-ci.org/onesky/onesky-ruby.svg)](https://travis-ci.org/onesky/onesky-ruby)

Ruby client for [OneSky](http://www.oneskyapp.com) [Platform API](https://github.com/onesky/api-documentation-platform)

## Installation

Add this line to your application's Gemfile:

    gem 'onesky-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onesky-ruby

## Usage

```Ruby
require 'onesky'

# Create client
client = Onesky::Client.new('<api_key>', '<api_secret>')

# list available locales
resp = JSON.parse(client.list_locale)
p resp['data']

# list project groups
resp = JSON.parse(client.list_project_group)
p resp['data']

# show project group details
project_group_id = 1
resp = JSON.parse(client.show_project_group project_group_id)
p resp['data']

# list projects
resp = JSON.parse(client.list_project project_group_id)
p resp['data']

### Work with Project

# show project details
project_id = 3
project = client.project(project_id)
resp = JSON.parse(project.show)
p resp['data']

# upload file
resp = project.upload_file(file: 'path/to/string/file', file_format: 'RUBY_YAML')
resp.code # => 201

# download translation
resp = project.export_translation(source_file_name: 'en.yml', locale: 'ja')
File.open('path/to/target/file', 'w') { |file| file.write(resp)}
```

## Contributing

1. Fork it ( http://github.com/onesky/onesky-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
