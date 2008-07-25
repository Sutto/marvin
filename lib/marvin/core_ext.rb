class String
  def /(other)
    File.join(self, other)
  end
end

class File
  def self.present_dir
    File.dirname(__FILE__)
  end
end