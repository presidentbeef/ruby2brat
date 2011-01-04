## Ruby2Brat

This is a very simplistic translator which converts (some subset of) Ruby code to [Brat](http://brat-lang.org) code.

### Build and Install

    gem build ruby2brat.gemspec
    gem install ruby2brat*.gem

### Run

`ruby2brat` will read in Ruby code from stdin and spit back Brat code on stdout. Piping it in works well:

    cat test.rb | ruby2brat > test.brat

### Test

From the base directory:

    ruby test/test.rb
