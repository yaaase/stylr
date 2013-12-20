require "stylr"

module Stylr
  describe DirLoader do
    let(:d) { DirLoader.new }

    it "loads all ruby files in a directory" do
      dir = "/Users/Thoughtworker/stylr/spec/dir"
      d.load_dir(dir)
      d.filenames.should == ["#{dir}/one.rb", "#{dir}/two.rb", "#{dir}/three.rb"].sort
    end

    it "loads all files even in a recursive structure" do
      dir = "/Users/Thoughtworker/stylr/spec/rdir"
      d.load_dir(dir)
      d.filenames.should == ["#{dir}/one/one.rb", "#{dir}/two/two.rb", "#{dir}/three/three.rb", "#{dir}/base.rb"].sort
    end
  end
end

