class Parser
  # permitted false values
  FALSE_VALUES = ['no', 'false', '0', false, 0]

  # permitted true values
  TRUE_VALUES = ['yes', 'true', '1', true, 1]

  # comment indicator
  COMMENT = ';'

  attr_accessor :overrides
  attr_accessor :output
  attr_accessor :current_group

  def load_config(file_path, overrides=[])
    @overrides = overrides.collect { |o| o.to_sym }
    @output = {}
    @current_group = @output

    # returns nil if an error was encountered
    ans = parse_file(file_path)

    # return nil to indicate issue
    return nil if ans.kind_of?(Exception)

    @output
  end

  # returns Exception if encountered an issue parsing file
  # builds up @output
  def parse_file(file_path)
    File.foreach(file_path) do |line|
      # parse current line
      # will return Exception if ecountered an issue
      ans = parse_line(line)

      # propigate terminating exception
      return ans if ans.kind_of?(Exception)
    end
  end

  # returns nil if encountered an issue parsing line
  # builds up @output
  def parse_line(line)
    # remove comments & whitespace from current line
    line = remove_comments(line)
    line = remove_whitespace(line)

    # skip parsing if line is empty
    return if line.empty?

    # is current line a group label
    if is_group_label?(line)
      # get the label to add to @output
      sym = extract_group_label(line).to_sym

      # configure output hash for new group
      @output[sym] = {}

      # provide reference to hash
      @current_group = @output[sym]
    else
      # current line is a setting assignment
      # will return Exception if encountered an issue processing setting assignment
      ans = parse_setting(line)

      return ans if ans.kind_of?(Exception)
    end
  end

  # returns nil if encountered an issue parsing setting assignment
  # builds up @output via @current_group (if set)
  def parse_setting(value)
    ex = Exception.new

    # not valid assignment
    return ex unless value.kind_of?(String)

    expression = value.split('=')

    # not a valid assignment if multiple assigments present
    return ex if expression.length != 2

    variable = remove_whitespace(expression[0])
    assignment = remove_whitespace(expression[1])

    # process override assignment first
    if is_variable_override?(variable)
      # returns Exception if variable or overried are not valid
      array = extract_variable_and_override(variable)
      return ex if array.nil?

      # valid variable and override values
      variable, override = array

      # should override be applied for current group
      if is_override?(override)
        # apply known value assignment operations
        # and assign to current group
        @current_group[variable.to_sym] = convert_assignment(assignment)
      end

      # finished processing, proceed to next line
      return
    end

    # current line is a regular setting assignment
    # return exception if not valid valid variable
    return ex unless is_variable?(variable)

    # apply known value assignment operations
    # and assign to current group
    @current_group[variable.to_sym] = convert_assignment(assignment)
  end

  def is_override?(value)
    # return false if no override provided at runtime
    return false if !@overrides.kind_of?(Array) || @overrides.empty? || !value.kind_of?(String)

    # @overrides is an array of symbols
    @overrides.include?(value.to_sym)
  end

  def group_label_regex
    /^\[([a-zA-Z_][a-zA-Z_0-9]*)\]$/
  end

  # returns true if value matches syntax for a group label
  # otherwise returns false
  # caller's responsibility to provide value without comments
  # example1:
  #   input: [test]
  #   output: true
  # example2:
  #   input: [[test]]
  #   output: false
  def is_group_label?(value)
    is_variable?(extract_group_label(value))
  end

  # returns string of group label variable
  # returns nil if able to extract group label
  def extract_group_label(value)
    if value.kind_of?(String) && group_label_regex === remove_whitespace(value)
      return group_label_regex.match(remove_whitespace(value)).captures.first
    end

    nil
  end

  # regex contatins a single capture
  # must start with a letter (upper/lower) or underscore
  # and may be followed by any number of letters, underscores, or numbers
  # no special characters are allowed
  def variable_regex
    /^([a-zA-Z_][a-zA-Z_0-9]*)$/
  end

  # returns true if valid ruby variable name
  # returns false otherwise
  # example1:
  #   input: 1test
  #   output: false
  # example2:
  #   input: _1_test
  #   output: true
  def is_variable?(value)
    variable_regex === remove_whitespace(value)
  end

  # regex contains two captures (variable, override)
  # matches variable<variable>
  # where variable is derived from variable_regex
  # must start with a letter (upper/lower) or underscore
  # and may be followed by any number of letters, underscores, or numbers
  # no special characters are allowed
  def variable_override_regex
    /^([a-zA-Z_][a-zA-Z_0-9]*)<([a-zA-Z_0-9]*)>/
  end

  # return true if valid variable override syntax
  # otherwise returns false
  # example1:
  #   input: var<test>
  #   output: true
  # example2:
  #   input: var<>
  #   output: false
  def is_variable_override?(value)
    if value.kind_of?(String) && variable_override_regex === value
      variables = value.split(/<|>/)

      # return if valid variables
      return variables.length == 2 && is_variable?(variables[0]) && is_variable?(variables[1])
    end

    # not a string or did not match variable regex
    false
  end

  # returns string of group label variable
  # returns nil if able to extract group label
  def extract_variable_and_override(value)
    value = remove_whitespace(value)
    if value.kind_of?(String) && is_variable_override?(value)
      return variable_override_regex.match(value).captures
    end

    nil
  end

  # returns a string with comment text removed
  # if non string arugment is provided, original object is returned
  # example1:
  #   input: [test] ; comment text
  #   output: [test]
  #     note output contains trailing space
  # example2:
  #   input: paid_user_size_limit; = 3.14
  #   output: paid_user_size_limit
  def remove_comments(value)
    return value unless value.kind_of?(String)
    regex_str = "#{COMMENT}.*"

    # perform substitution in two steps
    # 1. remove comments with newlines as terminal & preserve newline
    regex_newline = Regexp.new("#{regex_str}\n")
    value = value.gsub(regex_newline, "\n")

    # 2. cleanup all remaining comments from string which are on single line
    regex = Regexp.new(regex_str)
    value.gsub(regex, '')
  end

  # returns a string with leading and trailing whitepsace removed
  # returns original argument if not a string
  # example1:
  #   input: '   this is a test   '
  #   output: 'this is a test'
  def remove_whitespace(value)
    return value.strip if value.kind_of?(String)

    value
  end

  # returns conditional value
  # method captures all right hand expression conversions
  # if boolean value is assigned, will be converted to true/false
  # if array sugar notation is used, value will be expanded into correct array
  # if integer is provided, will be converted to an integer from a string
  # note boolean is handled before integer, 0 & 1 are treated as booleans over integers
  def convert_assignment(value)
    if is_boolean?(value)
      return convert_to_boolean(value)
    end

    if is_array_sugar?(value)
      return convert_array_sugar(value)
    end

    # already treating zero as boolean
    # if to_i returns 0, know to return original value
    # 0 is returned if to_i cannot process string
    # 'abcd'.to_i => 0
    integer = value.to_i

    integer == 0 ? value : integer
  end

  # return true if argument is a permitted boolean value
  # return false otherwise
  # permitted bool values are “yes”, “no”, “true”, “false”, 1, 0
  def is_boolean?(value)
    (FALSE_VALUES + TRUE_VALUES).include?(value)
  end

  # returns true if value is equivalent to true
  # false if value is equivalent to false
  # or nil if not a boolean value
  def convert_to_boolean(value)
    return nil unless is_boolean?(value)
    return false if FALSE_VALUES.include?(value)
    return true if TRUE_VALUES.include?(value)
  end

  # returns true or false
  def is_array_sugar?(value)
    value.kind_of?(String) && value.include?(',') &&
      # exclude string literals with matching '' or "" from sugar match
      !((value[0] == "'" && value[-1] == "'") ||
      (value[0] == '"' && value[-1] == '"'))
  end

  # returns string array if string array sugar is present
  # otherwise returns original argument
  # string array sugar is comma separated list of values
  # example1:
  #   input: array,of,values
  #   output: ['array', 'of', 'values']
  # example2:
  #   input: /ect/var/uploads
  #   output: /ect/var/uploads
  def convert_array_sugar(value)
    if is_array_sugar?(value)
      # remove leading/trailing whitespace from each element
      return value.split(',').collect! { |v| v.strip }
    end

    value
  end
end

class ::Hash
  # overload method missing for hash class
  # to acheive dot notation accessor
  def method_missing(method, *args, &block)
    return self[method] unless self[method].nil?
    nil
  end
end
