module Helpers
  def fixture_path(name)
    File.absolute_path(File.join(__dir__, "fixtures", name))
  end
end
