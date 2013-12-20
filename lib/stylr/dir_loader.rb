class DirLoader
  attr_reader :filenames

  def load_dir(dir)
    Dir.chdir File.expand_path(dir) do
      @filenames = Dir.glob('**/*.rb').map{|file| File.expand_path(file)}
    end
    @filenames.reject! do |filename|
      filename =~ /(_spec|_test).rb$/
    end
  end
end

