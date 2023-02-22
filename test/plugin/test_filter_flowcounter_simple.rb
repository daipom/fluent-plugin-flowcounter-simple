require_relative '../helper'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_flowcounter_simple'

class FlowCounterSimpleFilterTest < Test::Unit::TestCase
  include Fluent

  def setup
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  CONFIG = %[
    unit second
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::FlowCounterSimpleFilter).configure(conf)
  end

  def test_filter
    msgs = []
    10.times do
      msgs << {'message'=> 'a' * 100}
      msgs << {'message'=> 'b' * 100}
    end
    d = create_driver
    filtered, logs = filter(d, msgs)
    assert_equal msgs, filtered
    assert { logs.any? { |log| log.include?("count:20") } }
  end

  private

  def filter(d,  msgs)
    d.run(default_tag: 'test') {
      msgs.each {|msg|
        d.feed(msg)
      }
      d.instance.flush_emit(0)
    }
    [d.filtered_records, d.logs]
  end
end
