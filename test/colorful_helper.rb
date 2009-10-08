ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

# http://codesnippets.joyent.com/posts/show/522
module Test::Unit::Assertions
  def assert_block(message="assert_block failed.") # :yields:
    _wrap_assertion do
      if (! yield)
        logger.debug("\e[0;41mFailure:\e[m #{message}")
        raise Test::Unit::AssertionFailedError.new(message.to_s)
      else
        logger.debug("\e[0;32mSuccess\e[m")
      end
    end
  end
end

class Test::Unit::TestCase

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def log_test_name(test_name=nil)
    test_name = caller[0].match(/`(test_[a-z_]+)'$/) unless test_name
    logger.debug "\n\e[1m#{self.class}::\e[0;31m#{test_name}\e[m\n"
  end

end
