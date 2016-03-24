Assumptions
-----------
All work must be original and no third-party gems can be used to solve the challenge

Grammar
-------
```
line              ::= group_label | setting | comment | empty
group_label       ::= [variable]
setting           ::= variable = value | variable_override = value
comment           ::= ;[.*\n]
variable_override ::= variable<variable>
variable          ::= [_|[A-Z]|[a-z]][_|[A-Z]|[a-z]]*
value             ::= boolean | array_sugar | string | integer
boolean           ::= 0 | 1 | true | false | '0' | '1' | 'true' | 'false' | 'yes' | 'no'
array_sugar       ::= string,string
empty             ::= ''
```
Groups
-----
* Group labels must exist on their own line
* Groups labels cannot be nested
* Group label must be valid ruby variable
* Config load will terminate if lable is not valid variable name
* A group without any setting statements returns an empty hash
* Accessing group label returns symbolized hash of assignments
* Group labels may be defined multiple times, but last definition is persisted

Settings
--------
* Settings are scoped to each group
* Any setting defined above a group label is considered a top level item
* A setting cannot span more than a single line
* A setting that terminates without a complete assignment is invalid and will terminate
* Whenever seen, the values 0, 1 are treated as boolean values and not integers
* Numeric expressions included in value assignments will not be evaluated
* Ruby array literal syntax is not used for values

Overrides
---------
* overrides are provided as string or symbols that are case sensitive
* for example if the override is defined in the config
* path<Ubuntu> but the override provided is 'ubuntu' the config value is NOT triggered

Usage
-----
To build gem

`
gem build parser.gemspec
`

To install gem

`
gem install parser-0.0.0.gem
`

To run the tests

bundle install (to include RSpec)

`
rspec spec/parser_spec.rb
`

To use

1. install gem
1. require 'parser'
1. @p = Parser.new
1. @p.load_cofig(file_path, overrides=[])
