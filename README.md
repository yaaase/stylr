<h1>stylr</h1>

Check if source code conforms to some elements of the Github Ruby Style Guidelines ( https://github.com/styleguide/ruby )

Kind of raw still.  Currently supports checking against the following:

* Line length (user-configurable)
* Missing parens around method definitions with parameters (ie, "def foo bar" is disallowed)
* Trailing whitespace of any kind
* Use of the 'and' or 'or' operators (&& and || are preferred)
* Use of 'then' on a multiline if/then construct
* Spacing around parens
* Spacing around brackets (this is a little broken on multi-line arrays)
* Spacing around curly braces (this is also a little broken)
* Using the keyword 'for'
* Spacing around commas
* Using tab characters instead of soft tabs
* Spacing around math operators (+, *, etc)

Optionally checks for some metaprogramming, which you might not want in a large, enterprise codebase with varied levels of skill on your development team.  This is not a condemnation of these practices - most of them are good, idiomatic Ruby.  You might not, however, want your junior developers checking in lots of metaprogrammed code.  Pass the '--meta' flag to enable these checks.

* eval
* class_eval
* instance_eval
* module_eval
* define_method
* send

All of these things are configurable via config.yml

Currently only checks one file at a time, as I have been too lazy to support directories, etc.

<b>Usage</b>

./stylr /path/to/source.rb           # normal checks

./stylr /path/to/source.rb --meta    # also check for use of metaprogramming
