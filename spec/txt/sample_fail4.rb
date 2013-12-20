class TextFail
  STRING = <<-EOS
    def initialize foo, bar
      and for or
    end
  EOS

  def puts_a_string
    """this is
    one dumb for and or
    big def foo bar, baz
    def foo bar, baz
    multiline string"""
  end
end
