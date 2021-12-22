# Dependanot

Dependanot is definitely not [Dependabot](https://github.com/dependabot).

## Installation

Install `dependanot` from https://rubygems.org.

    $ gem install dependanot

## Usage

`dependanot` is a CLI that can be invoked via `$ dependabot`. However, it's
meant to be used from a GitHub Action.

Here's an example that can be added to `.github/workflows/dependanot.yml`.

```yaml
name: dependanot
on:
  schedule:
    - cron: '42 * * * *'
jobs:
  bundler:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.0
      - run: gem install dependanot
      - run: dependabot scan --recursive --push $GITHUB_WORKSPACE
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

That's it! Consult the [GitHub Actions Documentation][1] to customize the
workflow or check out the [Examples repo][2].

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dependanot/cli.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[1]: https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions
[2]: https://github.com/dependanot/examples
