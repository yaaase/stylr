module Stylr
  class FileParser
    attr_reader :lines

    UniqueConstant = ";;;;;"

    def initialize(file_path, lint, display = false)
      @lines       = []
      @lint        = lint
      @display     = display
      @file_string = File.read(file_path)
    end

    def violations?(meta = false)
      pre_multiline_string_removal_length_check!
      remove_multiline_strings!
      assign_lines_with_numbers!

      @lines.each do |array|
        line, number = array
        @lint.violation?(line, number)
        @lint.exception_violation?(line, number)
        @lint.meta_violation?(line, number) if meta
      end

      if @lint.errors.any?
        display_errors if @display
        true
      else
        display_no_error_message if @display
        false
      end
    end

    def assign_lines_with_numbers!
      @file_string.each_with_index do |line, number|
        @lines << [line, number + 1]
      end
    end

    def pre_multiline_string_removal_length_check!
      @file_string.split(/\n/).each_with_index do |line, number|
        @lint.line_too_long_violation?(line, number + 1)
      end
    end

    def remove_multiline_strings!
      @file_string = @file_string.gsub(/\n/, UniqueConstant)
      @file_string = @lint.strip_multiline_strings(@file_string)
      @file_string = @file_string.gsub(/#{UniqueConstant}/, "#{UniqueConstant}\n")
      @file_string = @file_string.split(/#{UniqueConstant}/)
    end

    def display_no_error_message
      puts "Your file is free of errors."
      puts
    end

    def display_errors
      puts "You have the following errors:"
      @lint.errors.each do |hash|
        error = hash.keys.first
        line_number = hash.values.first
        puts "Line #{line_number}: #{@lint.send(error)}"
      end
      puts
    end
  end
end
