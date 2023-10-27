class Test
  private def pri_1
    :pri_1
  end

  protected def pro_1
    :pro_1
  end

  def pub
    :pub
  end

  protected

  def pro_2
    :pro_2
  end

  private

  def pri_2
    :pri_2
  end

  public

  def pri_3
    :pri_3
  end

  private attr_accessor :baz

  def pub_1
    :pub_1
  end

  def pri_4
    :pri_4
  end

  attr_accessor :foo

  private :pri_3, :pri_4, :foo=

  def self.class_priv = :class_priv

  def pub_2 = :pub_2

  def self.class_pub = :class_pub

  private_class_method :new, :class_priv, :class_pub

  public_class_method :class_pub
end
