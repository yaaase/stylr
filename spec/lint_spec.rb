require "stylr"

module Stylr
  describe Lint do
    let(:l) { Lint.new(YAML.load_file('stylr.yml')) }

    context "#violation?" do
      context "missing_parens" do
        it "wants parens around method definitions with args" do
          l.violation?("def foo bar, baz").should be_true
        end

        it "does not need parens for methods with no args" do
          l.violation?("def some_method").should be_false
        end

        it "using parens is good" do
          l.violation?("def foo(bar, baz)").should be_false
        end

        it "using parens for methods with bang is the same" do
          l.violation?("def foo!").should be_false
        end

        it "a bang method with args needs parens too" do
          l.violation?("def foo! bar").should be_true
        end

        it "a question mark method without args is fine" do
          l.violation?("def foo?").should be_false
        end

        it "a question mark method with args needs parens" do
          l.violation?("def foo? bar").should be_true
        end

        it "class methods with bang+no args are fine" do
          l.violation?("def self.foo!").should be_false
        end

        it "class methods with bang+args need parens" do
          l.violation?("def self.foo! bar").should be_true
        end

        it "class methods with qmark+no args are fine" do
          l.violation?("def self.foo?").should be_false
        end

        it "class methods with qmark+args need parens" do
          l.violation?("def self.foo? bar").should be_true
        end

        it "positive case for bang" do
          l.violation?("def foo!(bar)").should be_false
        end

        it "positive case for class method bang" do
          l.violation?("def self.foo!(bar)").should be_false
        end

        it "positive case for qmark" do
          l.violation?("def foo?(bar)").should be_false
        end

        it "positive case for class method qmark" do
          l.violation?("def self.foo?(bar)").should be_false
        end

        it "acts the same for class methods" do
          l.violation?("def self.something foo, bar").should be_true
        end

        it "no parens for class methods without args is fine too" do
          l.violation?("def self.something").should be_false
        end

        it "arrays of args too need parens in the method def" do
          l.violation?("def foo *args").should be_true
        end
      end

      context "operator spacing" do
        it "spaces around + are good" do
          l.violation?("2+2").should be_true
        end

        it "on both sides" do
          l.violation?("2 +2").should be_true
        end

        it "but += is ok" do
          l.violation?("x += 2").should be_false
        end

        it "same with -" do
          l.violation?("2-2").should be_true
        end

        it "-= is fine" do
          l.violation?("x -= 3").should be_false
        end
      end

      context "soft tabs" do
        it "don't use actual tabs" do
          l.violation?("\t").should be_true
        end
      end

      context "space after open paren/bracket or before close paren/bracket" do
        it "space after open paren is bad" do
          l.violation?("def foo( bar)").should be_true
        end

        it "space before close paren is also bad" do
          l.violation?("def foo(bar )").should be_true
        end

        it "space after open bracket is bad" do
          l.violation?("list = [ 1, 2, 3]").should be_true
        end

        it "newline after open bracket is fine" do
          l.violation?("list = [\n").should be_false
        end

        it "close bracket fine as only thing on a line" do
          l.violation?("       ]").should be_false
        end
      end

      context "space around { and } is good" do
        it "no space before { is bad" do
          l.violation?("lambda{puts :foo}").should be_true
        end

        it "no space before } is bad" do
          l.violation?("lambda { puts :foo}").should be_true
        end

        it "no space after { is also bad" do
          l.violation?("{:foo }").should be_true
        end

        it "no space after } is fine" do
          l.violation?("lambda { puts :foo }.call").should be_false
        end
      end

      context "space after commas" do
        it "should have a space after a comma" do
          l.violation?("[1,2,3]").should be_true
        end

        it "can also pass..." do
          l.violation?("[1, 2, 3]").should be_false
        end

        it "newline after a comma is fine" do
          l.violation?(":a => 1,\n").should be_false
        end
      end

      context "line_too_long" do
        it "dislikes lines of >= 80 chars" do
          l.line_too_long_violation?("#{'a' * 80}").should be_true
        end
      end

      context "trailing_whitespace" do
        it "whitespace at the end of the line is a no-no" do
          l.violation?("def foo(bar) ").should be_true
        end

        it "a newline is ok by itself" do
          l.violation?("\n").should be_false
        end
      end

      context "and and or" do
        it "the word 'and' is banned" do
          l.violation?("foo and bar").should be_true
        end

        it "the word 'or' is also banned" do
          l.violation?("1 or nil").should be_true
        end
      end

      context "for loops" do
        it "generally you should not use for loops" do
          l.violation?("for x in list do").should be_true
        end
      end

      context "multiline if then" do
        it "should not use then in multiline if" do
          l.violation?("if foo then\nbar\nend").should be_true
        end

        it "single line if then end is ok" do
          l.violation?("if true then false end").should be_false
        end
      end

      context "multiline strings" do
        it "ignores multiline strings" do
          l.strip_multiline_strings("sql = <<-SQL for and or SQL").should == "sql = \"\""
        end

        it "ignores the other kind too" do
          l.strip_multiline_strings('"""foo bar baz"""').should == '""'
        end
      end

      context "comments" do
        it "ignores comments" do
          l.violation?("# a comment").should be_false
        end

        it "ignores comments even when they otherwise violate the rules" do
          l.violation?("# def foo bar").should be_false
        end

        it "does not care what violation the comment breaks" do
          l.violation?("# and or def foo bar, baz").should be_false
        end

        it "ignores indented comments" do
          l.violation?(" # def foo bar").should be_false
        end

        it "ignores comments indented with soft tabs" do
          l.violation?("  # def foo bar").should be_false
        end
      end
    end

    context "#meta_violation?" do
      it "can optionally check for metaprogramming" do
        l.meta_violation?("eval").should be_true
      end

      it "fucking HATES define_method" do
        l.meta_violation?("define_method").should be_true
      end

      it "dynamic method invocation via send is bad, mmkay?" do
        l.meta_violation?('foo.send "foo_#{:bar}"').should be_true
      end

      it "class eval, why not?" do
        l.meta_violation?("class_eval &block").should be_true
      end

      it "module eval is also naughty" do
        l.meta_violation?("module_eval foo").should be_true
      end

      it "and even instance eval!" do
        l.meta_violation?("instance_eval &block").should be_true
      end
    end

    context "#exception_violation?" do
      it "rescuing Exception is bad" do
        l.exception_violation?("rescue Exception").should be_true
      end

      it "rescuing nothing is the same as rescuing Exception" do
        l.exception_violation?("rescue    ").should be_true
      end

      it "rescuing an exception that ends with Exception is ok" do
        l.violation?("rescue MyCustomException").should be_false
      end
    end

    context "string stripping" do
      it "removes strings so it doesn't break on them" do
        l.strip_strings("def foo(\"bar\")").should == "def foo(\"\")"
      end

      it "does the same with single-quoted strings" do
        l.strip_strings("def foo('bar')").should == "def foo('')"
      end
    end

    context "error messages" do
      it "keeps track of your mistakes and their lines, defaulting to line #1" do
        l.violation?("def foo bar")
        l.errors.first.values.should == [1]
      end

      it "knows what line number you fucked up on" do
        l.violation?("def foo bar", 3)
        l.errors.first.values.should == [3]
      end

      it "everything has an error message" do
        expect do
          l.violations.values.each do |violation|
            l.messages.fetch(violation)
          end
          l.exception_violations.values.each do |exception_violation|
            l.messages.fetch(exception_violation)
          end
          l.metaprogramming_violations.values.each do |metaprogramming_violation|
            l.messages.fetch(metaprogramming_violation)
          end
        end.to_not raise_error
      end
    end

    context "#method_missing" do
      it "implements method_missing intelligently" do
        expect { l.foo }.to raise_error
      end
    end
  end
end
