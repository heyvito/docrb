class Docrb::App::Test
  extend Docrb::ExtendsA
  extend Docrb::ExtendsB
  extend Docrb::ExtendsC, Docrb::ExtendsD

  def self.test_1
    true
  end

  class << self
    def self.test_2
      false
    end
  end

  def test_3
    true
  end
end

class << Docrc::App::Test
  def self.test_4
    false
  end

  def test_5
    true
  end
end
