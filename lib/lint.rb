require 'yaml'

class Lint
  @@config = YAML.load_file('../config.yml')
  attr_reader :errors

  LineTooLongViolations = {
    /.{#{@@config["line_length"]}}+/ => :line_too_long
  }

  Violations = {
    /def (self\.)?\w+[!?]? .\w+/  => :missing_parens,
    /( )+$/                       => :trailing_whitespace,
    /\band\b/                     => :the_word_and,
    /\bor\b/                      => :the_word_or,
    /\bfor\b/                     => :the_word_for,
    /\bif\b.*\bthen\b\n/          => :multiline_if_then,
    /\(\s|\s\)/                   => :paren_spacing,
    /\[\s|\s\]/                   => :bracket_spacing,
    /[^\s][{}]|{[^\s]/            => :brace_spacing,
    /,[^ \n]/                     => :comma_spacing,
    /\t/                          => :no_soft_tabs,
    /[^\s]\+/                     => :no_operator_spaces,
    /\+[^\s=]/                    => :no_operator_spaces,
    /[^\s]-/                      => :no_operator_spaces
  }

  ExceptionViolations = {
    /rescue\s*(Exception)?$/      => :rescue_class_exception
  }

  MetaprogrammingViolations = {
    /\beval\b/                    => :used_eval,
    /\bclass_eval\b/              => :used_class_eval,
    /\bmodule_eval\b/             => :used_module_eval,
    /\binstance_eval\b/           => :used_instance_eval,
    /\bdefine_method\b/           => :used_define_method,
    /\w+\.send.*".*#\{/           => :dynamic_invocation
  }

  CommentedLine = [
    /^\s*#/
  ]

  Messages = {
    :missing_parens               => "You have omitted parentheses from a method definition with parameters.",
    :line_too_long                => "Line length of 80 characters or more.",
    :trailing_whitespace          => "Trailing whitespace.",
    :used_eval                    => "Used eval.",
    :used_define_method           => "Used define_method.",
    :dynamic_invocation           => "Dynamic invocation of a method.",
    :rescue_class_exception       => "Rescuing class Exception.",
    :the_word_and                 => "Used 'and'; please use && instead.",
    :the_word_or                  => "Used 'or'; please use || instead.",
    :the_word_for                 => "Used 'for'; please use an enumerator, or else explain yourself adequately to the team.",
    :multiline_if_then            => "Used 'then' on a multiline if statement.",
    :used_class_eval              => "Used class_eval.",
    :used_module_eval             => "Used module_eval.",
    :used_instance_eval           => "Used instance_eval.",
    :paren_spacing                => "Space after ( or before ).",
    :bracket_spacing              => "Space after [ or before ].",
    :brace_spacing                => "No space around { or before }.",
    :comma_spacing                => "No space after a comma.",
    :no_soft_tabs                 => "Used tab characters; please use soft tabs.",
    :no_operator_spaces           => "Please use spaces around operators."
  }

  def initialize
    @errors = []
  end

  def line_too_long_violation?(line, number = 1)
    abstract_violation?(LineTooLongViolations, line, number)
  end

  def violation?(line, number = 1)
    line = strip_strings(line)
    abstract_violation?(Violations, line, number)
  end

  def meta_violation?(line, number = 1)
    abstract_violation?(MetaprogrammingViolations, line, number)
  end

  def exception_violation?(line, number = 1)
    abstract_violation?(ExceptionViolations, line, number)
  end

  def abstract_violation?(list, line, number)
    list.each do |pattern, error|
      CommentedLine.each do |comment|
        return false if line[comment]
      end

      if line[pattern]
        @errors << { error => number }
        return true
      end
    end
    return false
  end
  private :abstract_violation?

  def strip_multiline_strings(string)
    string.tap do |str|
      str.gsub!(/""".*"""/, '""')
      start = /<<-?[A-Z]+/
      finish = (str[start] || "")[/[A-Z]+/]
      regexp = /#{start}.*\b#{finish}\b/
      str.gsub!(/#{str[regexp]}/,'""') if str[regexp]
    end
  end

  def strip_strings(line)
    line.gsub(/".*"/, '""').gsub(/'.*'/, "''")
  end

  def method_missing(method_name, *args, &block)
    if Messages.keys.include?(method_name.to_sym)
      Messages[method_name]
    else
      super(method_name, *args, &block)
    end
  end
end
