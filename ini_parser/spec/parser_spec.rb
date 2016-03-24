require 'spec_helper'
require 'byebug'
require_relative '../lib/parser'

describe Parser do
  before :each do
    @p = Parser.new
  end

  describe 'constants' do
    it 'should return TRUE_VALUES' do
      expect(Parser::TRUE_VALUES).to eq(['yes', 'true', '1', true, 1])
    end

    it 'should return FALSE_VALUES' do
      expect(Parser::FALSE_VALUES).to eq(['no', 'false', '0', false, 0])
    end

    it 'should return COMMENT' do
      expect(Parser::COMMENT).to eq(';')
    end
  end

  describe 'boolean methods' do
    describe 'is_boolean?' do
      it 'should return true when provided true' do
        expect(@p.is_boolean?(true)).to be true
      end

      it 'should return true when provided string true' do
        expect(@p.is_boolean?('true')).to be true
      end

      it 'should return true when provided false' do
        expect(@p.is_boolean?(false)).to be true
      end

      it 'should return true when provided string false' do
        expect(@p.is_boolean?('false')).to be true
      end

      it 'should return true when provided string no' do
        expect(@p.is_boolean?('no')).to be true
      end

      it 'should return true when provided string yes' do
        expect(@p.is_boolean?('yes')).to be true
      end

      it 'should return true when provided number 1' do
        expect(@p.is_boolean?(1)).to be true
      end

      it 'should return true when provided string 1' do
        expect(@p.is_boolean?('1')).to be true
      end

      it 'should return true when provided number 0' do
        expect(@p.is_boolean?(0)).to be true
      end

      it 'should return true when provided string 0' do
        expect(@p.is_boolean?('0')).to be true
      end

      it 'should return false when provided nil' do
        expect(@p.is_boolean?(nil)).to be false
      end

      it 'should return false when provided empty string' do
        expect(@p.is_boolean?('')).to be false
      end
    end

    describe 'convert_to_boolean' do
      it 'should return true when provided true' do
        expect(@p.convert_to_boolean(true)).to be true
      end

      it 'should return true when provided string true' do
        expect(@p.convert_to_boolean('true')).to be true
      end

      it 'should return false when provided false' do
        expect(@p.convert_to_boolean(false)).to be false
      end

      it 'should return false when provided string false' do
        expect(@p.convert_to_boolean('false')).to be false
      end

      it 'should return false when provided string no' do
        expect(@p.convert_to_boolean('no')).to be false
      end

      it 'should return true when provided string yes' do
        expect(@p.convert_to_boolean('yes')).to be true
      end

      it 'should return true when provided number 1' do
        expect(@p.convert_to_boolean(1)).to be true
      end

      it 'should return true when provided string 1' do
        expect(@p.convert_to_boolean('1')).to be true
      end

      it 'should return false when provided number 0' do
        expect(@p.convert_to_boolean(0)).to be false
      end

      it 'should return false when provided string 0' do
        expect(@p.convert_to_boolean('0')).to be false
      end

      it 'should return nil when provided nil' do
        expect(@p.convert_to_boolean(nil)).to be nil
      end

      it 'should return nil when provided empty string' do
        expect(@p.convert_to_boolean('')).to be nil
      end
    end
  end

  describe 'is_array_sugar?' do
    it 'should return false if argument is not a string' do
      expect(@p.is_array_sugar?([])).to be false
    end

    it 'should return false if argument doesnt contain ,' do
      expect(@p.is_array_sugar?('test')).to be false
    end

    it 'should return true if argument contains commas ,' do
      expect(@p.is_array_sugar?('test,test')).to be true
    end

    it 'should return true if argument contains commas with spaces' do
      expect(@p.is_array_sugar?("test, \t test")).to be true
    end
  end

  describe 'convert_array_sugar' do
    it 'should return original value if not a string' do
      expect(@p.convert_array_sugar(1)).to eq(1)
    end

    it 'should return original value if string does not contain ,' do
      expect(@p.convert_array_sugar('abc')).to eq('abc')
    end

    it 'should return an array of strings if string contains ,' do
      expect(@p.convert_array_sugar('a,b')).to be_an(Array)
    end

    it 'should return an array with unchanged values' do
      expect(@p.convert_array_sugar('a,b')).to eq(['a', 'b'])
    end

    it 'should strip leading and trailing whitespace from elements' do
      expect(@p.convert_array_sugar('a,    b')).to eq(['a', 'b'])
    end

    it 'should include empty strings for empty enteries in sugar' do
      expect(@p.convert_array_sugar(' , ,')).to eq(['', ''])
    end
  end

  describe 'convert_assignment' do
    it 'should convert no to false' do
      expect(@p.convert_assignment('no')).to be false
    end

    it 'should convert yes to true' do
      expect(@p.convert_assignment('yes')).to be true
    end

    it 'should convert string false to false' do
      expect(@p.convert_assignment('false')).to be false
    end

    it 'should convert string true to false' do
      expect(@p.convert_assignment('true')).to be true
    end

    it 'should convert string 0 to false' do
      expect(@p.convert_assignment('0')).to be false
    end

    it 'should convert string 1 to true' do
      expect(@p.convert_assignment('1')).to be true
    end

    it 'should convert array sugar to string array' do
      expect(@p.convert_assignment('a,b')).to eq(['a', 'b'])
    end

    it 'should convert array empty array sugar' do
      expect(@p.convert_assignment('a,,b')).to eq(['a', '', 'b'])
    end

    it 'should convert array empty array sugar' do
      expect(@p.convert_assignment(',')).to eq([])
    end

    it 'should return original value if not boolean or array sugar' do
      expect(@p.convert_assignment('test')).to eq('test')
    end
  end

  describe 'is_group_label?' do
    it 'should return false if not string argument' do
      expect(@p.is_group_label?([])).to be false
    end

    it 'should return false if does not start with [' do
      expect(@p.is_group_label?('a')).to be false
    end

    it 'should return false if does not end with ]' do
      expect(@p.is_group_label?('a')).to be false
    end

    it 'should return false if empty brackets []' do
      expect(@p.is_group_label?('[]')).to be false
    end

    it 'should return false if does not contain valid variable' do
      expect(@p.is_group_label?('[1]')).to be false
    end

    it 'should return false if contains nested brackets' do
      expect(@p.is_group_label?('[_[]1]')).to be false
    end

    it 'should return true if contains valid variable' do
      expect(@p.is_group_label?('[_1]')).to be true
    end
  end

  describe 'extract_group_label' do
    it 'should return nil if agrument is not a string' do
      expect(@p.extract_group_label([])).to be_nil
    end

    it 'should return nil if string is not enclosed in brackets' do
      expect(@p.extract_group_label('test')).to be_nil
    end

    it 'should return nil if string is an empty bracket' do
      expect(@p.extract_group_label('[]')).to be_nil
    end

    it 'should return string if argument contains value in brackets' do
      expect(@p.extract_group_label('[a]')).to be_a(String)
    end

    it 'should return string between brackets' do
      expect(@p.extract_group_label('[test]')).to eq('test')
    end
  end

  describe 'remove_comments' do
    it 'should return original object if non-string argument provided' do
      expect(@p.remove_comments([])).to eq([])
    end

    it 'should return string when provided string' do
      expect(@p.remove_comments('test')).to be_a(String)
    end

    it 'should return original string if comment is not present' do
      expect(@p.remove_comments('test')).to eq('test')
    end

    it 'should return empty string if line starts with comment' do
      expect(@p.remove_comments('; This is a comment')).to eq('')
    end

    it 'should return truncated string if comment starts mid string' do
      expect(@p.remove_comments('path<staging> = /srv/uploads/; This is another comment')).to eq('path<staging> = /srv/uploads/')
    end

    it 'should treat nested comments as single comment' do
      expect(@p.remove_comments('text; comment1 ; comment 2')).to eq('text')
    end

    it 'should remove comments across multiple lines' do
      expect(@p.remove_comments("text ;comment\ntest;test")).to eq("text \ntest")
    end
  end

  describe 'remove_whitespace' do
    it 'should return original object if non-string argument provided' do
      expect(@p.remove_whitespace([])).to eq([])
    end

    it 'should call strip on string value' do
      expect_any_instance_of(String).to receive(:strip)
      @p.remove_whitespace('  a  ')
    end

    it 'should return string stripped of leading whitespace' do
      expect(@p.remove_whitespace("\t \n\rtest")).to eq('test')
    end

    it 'should return string stripped of trailing whitespace' do
      expect(@p.remove_whitespace("test\n\t   ")).to eq('test')
    end

    it 'should return string stripped of leading and trailing whitespace' do
      expect(@p.remove_whitespace("  \n \ttest\n\t   ")).to eq('test')
    end
  end

  describe 'is_variable?' do
    it 'should return true if starts with uppercase' do
      expect(@p.is_variable?('A')).to be true
    end

    it 'should return true if starts with lowercase' do
      expect(@p.is_variable?('a')).to be true
    end

    it 'should return true if starts with underscore' do
      expect(@p.is_variable?('_')).to be true
    end

    it 'should return true if contains mixed case' do
      expect(@p.is_variable?('aVariable')).to be true
    end

    it 'should return true if contains mixed case and underscores' do
      expect(@p.is_variable?('a_Variable')).to be true
    end

    it 'should return true if contains mixed case, underscores, numbers' do
      expect(@p.is_variable?('a_Variable2')).to be true
    end

    it 'should return false if starts with a number' do
      expect(@p.is_variable?('1')).to be false
    end

    it 'should return false if contains special characters' do
      expect(@p.is_variable?('a!')).to be false
      expect(@p.is_variable?('a@')).to be false
      expect(@p.is_variable?('a#')).to be false
      expect(@p.is_variable?('a$')).to be false
      expect(@p.is_variable?('a%')).to be false
      expect(@p.is_variable?('a^')).to be false
      expect(@p.is_variable?('a&')).to be false
      expect(@p.is_variable?('a*')).to be false
      expect(@p.is_variable?('a(')).to be false
      expect(@p.is_variable?('a)')).to be false
      expect(@p.is_variable?('a-')).to be false
      expect(@p.is_variable?('a=')).to be false
      expect(@p.is_variable?('a+')).to be false
      expect(@p.is_variable?('a[')).to be false
      expect(@p.is_variable?('a{')).to be false
      expect(@p.is_variable?('a]')).to be false
      expect(@p.is_variable?('a}')).to be false
      expect(@p.is_variable?('a\\')).to be false
      expect(@p.is_variable?('a|')).to be false
      expect(@p.is_variable?('a;')).to be false
      expect(@p.is_variable?('a:')).to be false
      expect(@p.is_variable?('a\'')).to be false
      expect(@p.is_variable?('a"')).to be false
      expect(@p.is_variable?('a<')).to be false
      expect(@p.is_variable?('a,')).to be false
      expect(@p.is_variable?('a>')).to be false
      expect(@p.is_variable?('a.')).to be false
      expect(@p.is_variable?('a?')).to be false
      expect(@p.is_variable?('a/')).to be false
    end

    it 'should strip whitespace from input before returning value' do
      expect(@p).to receive(:remove_whitespace)
      @p.is_variable?(' test ')
    end

    it 'should return true for string arguments with whitespace' do
      expect(@p.is_variable?(' test ')).to be true
    end
  end

  describe 'is_variable_override?' do
    it 'should return false if argument is not a string' do
      expect(@p.is_variable_override?([])).to be false
    end

    it 'should return false if argument is not in form variable<variable>' do
      expect(@p.is_variable_override?('test')).to be false
    end

    it 'should return false if argument is not a valid variable' do
      expect(@p.is_variable_override?('1test<1>')).to be false
    end

    it 'should return false if argument orverride is not a valid variable' do
      expect(@p.is_variable_override?('test<<a>')).to be false
    end

    it 'should return true if valid syntax' do
      expect(@p.is_variable_override?('test<a>')).to be true
    end
  end

  describe 'extract_variable_and_override' do
    it 'should return nil if not provided a string' do
      expect(@p.extract_variable_and_override([])).to be_nil
    end

    it 'should return nil if not valid variable override' do
      expect(@p.extract_variable_and_override('test<><>')).to be_nil
    end

    it 'should return nil if override is not a valid variable' do
      expect(@p.extract_variable_and_override('test<1>')).to be_nil
    end

    it 'should return an array if valid override' do
      expect(@p.extract_variable_and_override('test<example_1>')).to be_an(Array)
    end

    it 'should return an array of length 2 if valid override' do
      expect(@p.extract_variable_and_override('test<example_1>').length).to eq(2)
    end

    it 'should return variable and override if valid' do
      expect(@p.extract_variable_and_override('test<example_1>')).to eq(['test', 'example_1'])
    end
  end

  describe 'is_override?' do
    it 'should return false if argument is not a string' do
      @p.overrides = [:test]
      expect(@p.is_override?(15)).to be false
    end

    it 'should return false if override list is empty' do
      @p.overrides = []
      expect(@p.is_override?('test')).to be false
    end

    it 'should return false if argument is not in override list' do
      @p.overrides = [:example]
      expect(@p.is_override?('test')).to be false
    end

    it 'should return true if argument (string) is in override list' do
      @p.overrides = [:test]
      expect(@p.is_override?('test')).to be true
    end
  end

  describe 'parse_setting' do
    it 'should return an exception if provided non string argument' do
      expect(@p.parse_setting([])).to eq(Exception.new)
    end

    it 'should return an exception if does not contain assignment operator =' do
      expect(@p.parse_setting('test')).to eq(Exception.new)
    end

    it 'should return an exception if multiple assiments =' do
      expect(@p.parse_setting('test = test = test')).to eq(Exception.new)
    end

    it 'should return an exception if invalid variable assignment' do
      expect(@p.parse_setting('1 = 2')).to eq(Exception.new)
    end

    it 'should return an exception if invalid variable override syntax' do
      expect(@p.parse_setting('1<1>')).to eq(Exception.new)
    end

    it 'should assign override value to current group' do
      @p.overrides = [:test]
      @p.output = { example: {} }
      @p.current_group = @p.output.example

      @p.parse_setting('test<test> = one')

      expect(@p.output.example.test).to eq('one')
    end

    it 'should skip override assignment if not found in override list' do
      @p.overrides = [:test, :case]
      @p.output = { example: {} }
      @p.current_group = @p.output.example

      @p.parse_setting('test<one> = one')

      expect(@p.output.example).to eq({})
    end

    it 'should assign value to current group' do
      @p.overrides = [:test]
      @p.output = { example: {} }
      @p.current_group = @p.output.example

      @p.parse_setting('test = one')

      expect(@p.output.example.test).to eq('one')
    end

    # NOT VALID TEST
    it 'should return group level as symbolized hash' do
      @p.overrides = [:test, :case]
      @p.output = { example: { test: 1, test2: 2 } }
      @p.current_group = @p.output.example

      # @p.parse_setting('test<one> = one')

      expect(@p.output.example).to eq({ test: 1, test2: 2 })
    end

    # NOT VALID TEST
    it 'should return nil for non valid dot notation' do
      @p.overrides = [:test, :case]
      @p.output = { example: { test: 1, test2: 2 } }
      @p.current_group = @p.output.example

      # @p.parse_se/tting('test<one> = one')

      expect(@p.output.example.abc).to be_nil
    end
  end

  describe 'parse_line' do
    it 'should ignore comments' do

    end
  end

  describe 'load_config' do
    describe 'valid file structure' do
      before :each do
        @path = Dir.pwd + '/spec/fixtures/valid/'
      end

      it 'should return empty output if file is empty' do
        # test1.conf is an empty file
        expect(@p.load_config(@path + 'test1.conf')).to eq({})
      end

      it 'should return empty output if file contains comments' do
        # test2.conf contains a single comment
        expect(@p.load_config(@path + 'test2.conf')).to eq({})
      end

      it 'should set assignments outside of group levels' do
        # test3.conf top level setting assignments without any group labels
        expect(@p.load_config(@path + 'test3.conf')).to eq({ size: 10, bool: false, array: ["array", "of", "values"] })
      end

      it 'should return nil if group label was not set' do
        # test3.conf top level setting assignments without any group labels
        @output = @p.load_config(@path + 'test3.conf')
        expect(@output.random).to be_nil
      end

      it 'should apply top level assigment and ignore override' do
        # test4.conf top level setting assignments without any group labels
        expect(@p.load_config(@path + 'test4.conf')).to eq({ test: true })
      end

      it 'should apply top level assigment and and apply override (string)' do
        # test4.conf top level setting assignments without any group labels
        expect(@p.load_config(@path + 'test4.conf', ['false'])).to eq({ test: false })
      end

      it 'should apply top level assigment and and apply override (symbol)' do
        # test4.conf top level setting assignments without any group labels
        expect(@p.load_config(@path + 'test4.conf', [:false])).to eq({ test: false })
      end

      it 'should apply last override in file if multiple provided' do
        # test4.conf top level setting assignments without any group labels
        expect(@p.load_config(@path + 'test4.conf', [:false, :maybe])).to eq({ test: "maybe" })
      end

      it 'should handle top level assignment with comments' do
        # test5.conf top level setting assignments without any group labels
        expect(@p.load_config(@path + 'test5.conf')).to eq({ test: 12 })
      end

      it 'should set group label correctly' do
        # test6.conf single group label
        @output = @p.load_config(@path + 'test6.conf')
        expect(@output.valid).to eq({})
      end

      it 'should set group label and perform assignment' do
        # test7.conf single group label with assignment
        @output = @p.load_config(@path + 'test7.conf')
        expect(@output.valid.test).to eq(123)
      end

      it 'should set group label and perform assignment and ignore overrides' do
        # test8.conf single group label with assignment and override assignment
        @output = @p.load_config(@path + 'test7.conf')
        expect(@output.valid.test).to eq(123)
      end

      it 'should set group label and perform assignment and ignore overrides' do
        # test8.conf single group label with assignment and override assignment
        @output = @p.load_config(@path + 'test8.conf')
        expect(@output.valid.test).to eq(123)
      end

      it 'should set group label and perform boolean assignment' do
        # test8.conf single group label with assignment and override assignment
        @output = @p.load_config(@path + 'test8.conf')
        expect(@output.valid.bool).to be true
      end

      it 'should set group label and perform array sugar assignment' do
        # test8.conf single group label with assignment and override assignment
        @output = @p.load_config(@path + 'test8.conf')
        expect(@output.valid.ans).to eq(['some', 'thing'])
      end

      it 'should set group label and perform assignment with override (string)' do
        # test8.conf single group label with assignment and override assignment
        @output = @p.load_config(@path + 'test8.conf', ['arg'])
        expect(@output.valid.test).to eq('/path/to/location')
      end

      it 'should set group label and perform assignment with override (symbol)' do
        # test8.conf single group label with assignment and override assignment
        @output = @p.load_config(@path + 'test8.conf', [:arg])
        expect(@output.valid.test).to eq('/path/to/location')
      end

      it 'should set multiple group labels' do
        # test9.conf multiple group labels with assignment and override assignment
        @output = @p.load_config(@path + 'test9.conf', [:arg])

        expect(@output.valid.test).to eq('/path/to/location')
        expect(@output.valid2.test).to eq('/path/to/location')
      end

      it 'should set multiple group labels with spaces and comments' do
        # test10.conf example provided in problem statement
        @output = @p.load_config(@path + 'test10.conf', ['production', :ubuntu])

        expect(@output.common.path).to eq('/srv/var/tmp/')
        expect(@output.common.student_size_limit).to eq(52428800)

        expect(@output.http.params).to eq(['array', 'of', 'values'])

        expect(@output.ftp.lastname).to be_nil
        expect(@output.ftp.enabled).to be false

        expect(@output.ftp).to eq({ name: '"hello there, ftp uploading"', path: '/etc/var/uploads', enabled: false })
      end

      it 'should set multiple group labels with spaces and comments' do
        # test9.conf multiple group labels with assignment and override assignment
        @output = @p.load_config(@path + 'test10.conf', ['production', :ubuntu])

        expect(@output.common.path).to eq('/srv/var/tmp/')
        expect(@output.common.student_size_limit).to eq(52428800)

        expect(@output.http.params).to eq(['array', 'of', 'values'])

        expect(@output.ftp.lastname).to be_nil
        expect(@output.ftp.enabled).to be false

        expect(@output.ftp).to eq({ name: '"hello there, ftp uploading"', path: '/etc/var/uploads', enabled: false })
      end
    end

    describe 'invalid file structure' do
      before :each do
        @path = Dir.pwd + '/spec/fixtures/invalid/'
      end

      it 'should return nil if setting variable is not valid' do
        expect(@p.load_config(@path + 'test1.conf')).to be_nil
      end

      it 'should return nil if setting variable with override is not valid' do
        expect(@p.load_config(@path + 'test2.conf')).to be_nil
      end

      it 'should return nil if setting override variable is not valid' do
        expect(@p.load_config(@path + 'test3.conf')).to be_nil
      end

      it 'should return nil if group label is not valid' do
        expect(@p.load_config(@path + 'test4.conf')).to be_nil
      end

      it 'should return nil if assignment value is not present' do
        expect(@p.load_config(@path + 'test4.conf')).to be_nil
      end
    end
  end
end
