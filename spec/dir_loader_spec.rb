require "stylr"

module Stylr
  describe DirLoader do
    let(:d) { DirLoader.new }

    it "loads all ruby files in a directory" do
      dir = File.join(Dir.pwd, 'spec', 'dir')
      d.load_dir(dir)
      d.filenames.sort.should == ["#{dir}/one.rb", "#{dir}/two.rb", "#{dir}/three.rb"].sort
    end

    it "loads all files even in a recursive structure" do
      dir = File.join(Dir.pwd, 'spec', 'rdir')
      d.load_dir(dir)
      d.filenames.sort.should == ["#{dir}/one/one.rb", "#{dir}/two/two.rb", "#{dir}/three/three.rb", "#{dir}/base.rb"].sort
    end

    it "ignores specs" do
      dir = File.join(Dir.pwd, 'spec', 'sdir')
      d.load_dir(dir)
      d.filenames.should == []
    end

    it "takes optionally a list of directories to exclude" do
      dir = File.join(Dir.pwd, 'spec', 'rdir')
      ignores = File.join(Dir.pwd, 'spec', 'rdir', 'one')
      d.load_dir(dir, [ignores])
      d.filenames.sort.should == ["#{dir}/two/two.rb", "#{dir}/three/three.rb", "#{dir}/base.rb"].sort
    end
  end
end

