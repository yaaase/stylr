class Foo
  def something_risky(bar)
    begin
      # doesn't matter
    rescue
      nil
    end
  end
end
