# Through

A piping library with no dependency that let's you pipe anything you want from a basic string to a complex ActiveRecord query. Writing that pipeline that checks for arguments has never been so easy.

## Why?

I was tired of always writig the following query filtering in my Rails controller.
```ruby
class UsersController < ActionController
  def index
    query = Users
    if params["email"]
      query.where(email: params["email"])
    end
    # ... and a lots of other filter
  end
end
```

My controller started getting really bloat and I decided to extract them to classes so filtering is done at one specific place. Even though the original idea comes from a Rails usecase, I decided to decouple it as much as possible so it can serve other usecase.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'through'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install through

## Usage

### Our first pipeline

First step is to extend the Through class and start piping stuff.

```ruby
class StringPipe < Through::Pipe
end
```

These three principal macro can be used to pipe
- `pipe_with(key, options)`: Will pipe **only** if a specific key **is** provided to the `StringPipe`. For options, see section [options](#Options)
- `pipe_without(key, options)`: Will pipe **only** if a specific key **is not** provided to the `StringPipe`. For options, see section [options](#Options)
- `pipe(options)`: Will always pipe. For options, see section [options](#Options)

Once your class is ready to pipe, you instanciate an object with the basic item to pipe and call the `through(params)` method with the piping paramteres. Let's take this basic useless String concatenating example.

```ruby
class StringPipe < Through::Pipe
  pipe_with :is_dangerous do |str, is_dangerous, _|
    if (is_dangerous)
      str + " WARNING"
    else
      str
    end
  end

  pipe_without :safe do |st, _|
    str + " (not super safe, fill in a :safe parameter to remove this message)"
  end

  pipe do
    str + " always through this"
  end
end

StringPipe.new("Start:").through()
# => "Start: always through this (not super safe, fill in a :safe parameter to remove this message)"

StringPipe.new("Start:").through({ is_dangerous: true })
# => "Start: always through this WARNING (not super safe, fill in a :safe parameter to remove this message)"

StringPipe.new("Start:").through({ is_dangerous: true, safe: "" })
# => "Start: always through this WARNING"

StringPipe.new("Start:").through({ safe: "" })
# => "Start: always through this"
```

### Example using an ActiveRecord query

Let's take an actual example we have when we wanted to filter users within Rails ActiveRecord query

```ruby
class UsersQuery < Through::Pipe
  # If my params object contains a string key "email", the pipe will get through this
  pipe_with "email" do |query, email, _|
    query.where("users.email ilike :value", value: "%#{email}%")
  end

  # If my params object contains a string key "role_ids", the pipe will get through this
  pipe_with "role_ids" do |query, ids, _|
    query.where("users.role_id in (:ids)", ids: ids)
  end
end
```

With this `UsersQuery`, I can go ahead and filter a query easily
```ruby
  UsersQuery.new(User).through({
    "email" => "foo@bar.baz",
    "role_ids" => [1, 2, 3]
  })
```

```ruby
class UsersController < ActionController
  def index
    query = UsersQuery.new(User).through(params)
  end
end
```

## API

### Options

- `if`: Proc that recieve the parameter and the context that should return a boolean to check if a pipe should be piped. In a case of `pipe_with` or `pipe_without` the procedure will receive the parameter and the context. In the `pipe`, only the contnext is provided.

```ruby
class UsersQuery < Through::Pipe
  # Will only pipe if the email length is greater than 10
  pipe_with "email", if: -> (email, _) { email.length > 10 } do |query, email, _|
    query.where("users.email ilike :value", value: "%#{email}%")
  end
end
```

If you fill the if option to any of the following macro, it'll be evaluated before entering the pipe.

### `pipe_with(name, options) do |object, parameter, context|`

This pipe will only enter if the given key is provided. **The key type is important, if you write a `pipe :email`, parameter `{ "email" => "" }` will not be considered since it's a string**

### `pipe_without(name, options) do |object, parameter, context|`

This pipe will only enter if the given key **is not** provided. **The key type is important, if you write a `pipe :email`, parameter `{ "email" => "" }` will not be considered since it's a string**

### `pipe(options) do |object, parameter, context|`

This pipe will always enter. **The key type is important, if you write a `pipe :email`, parameter `{ "email" => "" }` will not be considered since it's a string**

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rumandcode/through.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
