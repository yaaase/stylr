class DirLoader
  attr_reader :filenames

  DEPTH = "**/**/**/**/**/**/**/**/**/**/**/**"

  def load_dir(dir)
    @filenames = Dir[File.expand_path(dir) + DEPTH].select { |f| File.file?(f) && f =~ /\.rb$/ }
  end

end

