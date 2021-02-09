[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/joel/homebrew-bam-lookup)

![Ruby](https://github.com/joel/homebrew-bam-lookup/workflows/Ruby/badge.svg)

# Bank Account Movements Lookup

BAM-Lookup is a CLI let you lookup into CSV files your Bank Account Movements.

```
lookup --expression amazon+prime --min -500 --max 0 --no-verbose --trunk 50 --label amazon_prime --source_file

┌────────────┬──────────┬────┬─────────┬──────┬───────┬──────────┬───────────┐
│Label       │Date      │Year│Month    │Day   │ Amount│Source Dir│Source File│
├────────────┼──────────┼────┼─────────┼──────┼───────┼──────────┼───────────┤
│amazon_prime│2019/09/02│2019│September│Monday│-€36.00│HelloBank │           │
│amazon_prime│2019/09/29│2019│September│Sunday│-€36.00│N26       │           │
│amazon_prime│2020/08/30│2020│August   │Sunday│-€36.00│N26       │           │
└────────────┴──────────┴────┴─────────┴──────┴───────┴──────────┴───────────┘
┌───────┬────────┐
│Average│Sum     │
├───────┼────────┤
│-€36.00│-€108.00│
└───────┴────────┘
┌────┬─────────┬───────┬───────┐
│Year│Month    │Average│    Sum│
├────┼─────────┼───────┼───────┤
│2019│September│-€36.00│-€72.00│
│2020│August   │  €0.00│-€36.00│
└────┴─────────┴───────┴───────┘
```

```
Usage: lookup --expression agua,endesa ---trunk 20 --min -200 --max 0 --label Agua [options]

Specific options:
    -e, --expression EXPRESSION      [REQUIRED] What label you are looking for, coma as separator (OR)
    -m, --max MAX                    [OPTIONAL] Keep only amount less than
    -a, --min MIN                    [OPTIONAL] Keep only amount greater than
    -l, --label LABEL                [OPTIONAL] Labelled the items
    -t, --trunk TRUNK                [OPTIONAL] Trunk label
    -v, --[no-]verbose               Run verbosely
    -w, --[no-]write                 Write the result in csv

Common options:
    -h, --help                       Show this message
        --version                    Show version
```

## Installation

### Homebrew

```
brew tap joel/homebrew-bam-lookup git@github.com:joel/homebrew-bam-lookup.git
brew install lookup
```

### Rubygem

Add this line to your application's Gemfile:

```ruby
gem 'bam_lookup'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install bam_lookup

## Configuration

You can indicate the directory where the CSV files lies [here](https://github.com/joel/bam-lookup/blob/f968a23450b021f1d173bbcc6770bef0b7f7b309/bin/lookup.rb#L8)

or pass the path with `--source_directory`

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bam_lookup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/bam_lookup/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BamLookup project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/bam_lookup/blob/master/CODE_OF_CONDUCT.md).
