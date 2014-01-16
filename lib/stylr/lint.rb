require 'yaml'
require 'ripper'

class Lint
  attr_reader :errors, :violations, :exception_violations, :metaprogramming_violations, :messages

  def initialize(config = nil)
    @errors = []
    @config = config || YAML.load_file(File.join(Dir.pwd, 'stylr.yml'))
    setup_class_values
  end

  def line_too_long_violation?(line, number = 1)
    abstract_violation?(@line_too_long_violations, line, number)
  end

  def violation?(line, number = 1)
    line = strip_strings(line)
    line = remove_regex(line)
    abstract_violation?(@violations, line, number)
  end

  def meta_violation?(line, number = 1)
    abstract_violation?(@metaprogramming_violations, line, number)
  end

  def exception_violation?(line, number = 1)
    abstract_violation?(@exception_violations, line, number)
  end

  def strip_multiline_strings(string)
    string.tap do |str|
      str.gsub!(/""".*"""/, '""')
      start = /<<-?[A-Z]+/
      finish = (str[start] || "")[/[A-Z]+/]
      regexp = /#{start}.*\b#{finish}\b/
      str.gsub!(/#{str[regexp]}/, '""') if str[regexp]
    end
  end

  def strip_strings(line)
    line.gsub(/".*"/, '""').gsub(/'.*'/, "''")
  end

  def remove_regex(line)
    if possible_regex = line[/\/.*\//]
      sexp = Ripper.sexp(possible_regex) || []
      if sexp.flatten.grep(/regex/) # *looks at the ground sheepishly*
        return line.gsub(possible_regex, 'REGEX')
      end
    end
    line
  end

  private

  def abstract_violation?(list, line, number)
    list.each do |pattern, error|
      @commented_line.each do |comment|
        return false if line[comment]
      end

      if line[pattern]
        @errors << { error => number }
        return true
      end
    end
    return false
  end

  def setup_class_values
    @line_too_long_violations = {
      /.{#{@config["line_length"]}}+/ => :line_too_long
    }.delete_if { |_, v| !@config[v.to_s] }

    @violations = {
      /def (self\.)?\w+[!?]? .\w+/  => :missing_parens,
      /( )+$/                       => :trailing_whitespace,
      /\band\b/                     => :the_word_and,
      /\bor\b/                      => :the_word_or,
      /\bfor\b/                     => :the_word_for,
      /\bif\b.*\bthen\b\n/          => :multiline_if_then,
      /\(\s|\s\)/                   => :paren_spacing,
      /\[[^\S\n]/                   => :bracket_spacing,
      /\S.*\s\]/                    => :bracket_spacing,
      /[^\s][{}]|{[^\s]/            => :brace_spacing,
      /,[^ \n]/                     => :comma_spacing,
      /\t/                          => :no_soft_tabs,
      /===/                         => :triple_equals,
      /[^\s]\+/                     => :no_operator_spaces,
      /\+[^\s=]/                    => :no_operator_spaces,
      /[^\s]-/                      => :no_operator_spaces
    }.delete_if { |_, v| !@config[v.to_s] }

    @exception_violations = {
      /rescue\s*(Exception)?$/      => :rescue_class_exception
    }.delete_if { |_, v| !@config[v.to_s] }

    @metaprogramming_violations = {
      /\beval\b/                    => :used_eval,
      /\bclass_eval\b/              => :used_class_eval,
      /\bmodule_eval\b/             => :used_module_eval,
      /\binstance_eval\b/           => :used_instance_eval,
      /\bdefine_method\b/           => :used_define_method,
      /\w+\.send.*".*#\{/           => :dynamic_invocation,
      /def\s+method_missing/        => :used_method_missing,
      /respond_to_missing\?/        => :used_respond_to_missing
    }.delete_if { |_, v| !@config[v.to_s] }

    @commented_line = [
      /^\s*#/
    ]

    @messages = {
      :missing_parens               => "You have omitted parentheses from a method definition with parameters.",
      :line_too_long                => "Line length of #{@config['line_length']} characters or more.",
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
      :used_method_missing          => "Please do not override method_missing.",
      :used_respond_to_missing      => "Please do not use respond_to_missing?.",
      :paren_spacing                => "Space after ( or before ).",
      :bracket_spacing              => "Space after [ or before ].",
      :brace_spacing                => "No space around { or before }.",
      :comma_spacing                => "No space after a comma.",
      :no_soft_tabs                 => "Used tab characters; please use soft tabs.",
      :triple_equals                => "Use of triple-equals.",
      :no_operator_spaces           => "Please use spaces around operators."
    }
  end

  def method_missing(method_name, *args, &block)
    if @messages.keys.include?(method_name.to_sym)
      @messages[method_name]
    else
      super(method_name, *args, &block)
    end
  end
end
