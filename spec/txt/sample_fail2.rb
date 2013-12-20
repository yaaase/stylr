class Foo
  def initialize(bar)
    @bar = bar
  end

  def some_bad_metaprogrammed_method(foo)
    @bar.send("call_#{foo}")
  end
end
