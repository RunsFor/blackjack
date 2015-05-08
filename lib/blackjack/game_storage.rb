class Blackjack::GameStorage
  def initialize(filename)
    @filename = filename
  end

  def all
    if File.exist?(@filename)
      Marshal.load(File.read(@filename))
    else
      []
    end
  end

  def first
    all.first
  end

  def store(*games)
    if File.exist?(@filename)
      File.open(@filename, 'w') { |file| Marshal.dump(games, file) }
    end
  end

  def delete_all
    if File.exist?(@filename)
      File.open(@filename, 'w') { |file| Marshal.dump([], file) }
    end
  end
end
