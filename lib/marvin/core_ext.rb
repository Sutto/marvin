class File
  def self.present_dir
    File.dirname(__FILE__)
  end
end

class String
  def /(*args)
    File.join(self, *args)
  end
end