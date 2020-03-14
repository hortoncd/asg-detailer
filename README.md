# AsgDetailer

![](https://github.com/hortoncd/asg-detailer/workflows/Ruby/badge.svg)

I found myself wanting to be able to quickly see what a typical AWS ASG and ELB setup looked like without poking away at the interface or needing to use multiple command-line tools.  This is a small gem to detail some of the basics of that style setup.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'asg-detailer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install asg-detailer

## Usage

The gem relies on the aws-sdk, which uses env vars to set AWS auth.

`
export AWS_ACCESS_KEY_ID=<YOUR AWS ID>
export AWS_SECRET_ACCESS_KEY=<YOUR AWS KEY>
export AWS_REGION=us-west-2
`

It requires an ASG name as an arg.

`asg-detailer <asg name>`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hortoncd/asg-detailer
