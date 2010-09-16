class Log < ActiveRecord::Base

  def write(trace=nil, &block)
    text = trace.nil? ? yield : trace
    Log.create!(attributes.merge({:text => text}))
  end

  alias :debug :write

  def read
    "[#{created_at.strftime('%H:%M:%S')}]  #{text}"
  end
end
