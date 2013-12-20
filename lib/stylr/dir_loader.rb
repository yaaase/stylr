class DirLoader
  attr_reader :filenames

  DEPTH = "**/**/**/**/**/**/**/**/**/**/**/**" # lol wut

  def load_dir(dir)
    @filenames = Dir[File.expand_path(dir) + DEPTH].select do |f|
      File.file?(f) &&
        f =~ /\.rb$/
    end.reject do |f|
        f =~ /_spec\.rb$/ || f =~ /_test\.rb$/
    end
  end

end

