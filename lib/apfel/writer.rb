module Apfel
  class Writer
    def self.write(file, data)
      File.open(file, 'w') do |f| 
        f.write(data)
      end
    end
  end
end