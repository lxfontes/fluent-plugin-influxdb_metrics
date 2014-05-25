require 'test/unit'

require 'fluent/test'
require 'fluent/plugin/out_influxdb_metrics'

require 'webmock/test_unit'
require 'date'

require 'helper'

$:.push File.expand_path("../lib", __FILE__)
$:.push File.dirname(__FILE__)

WebMock.disable_net_connect!

class InfluxdbMetricsOutput < Test::Unit::TestCase
  attr_accessor :index_cmds, :index_command_counts

  def setup
    Fluent::Test.setup
    @driver = nil
  end

  def driver(tag='test', conf='')
    @driver ||= Fluent::Test::BufferedOutputTestDriver.new(Fluent::InfluxdbMetricsOutput, tag).configure(conf)
  end

  def sample_record
    {'age' => 26, 'request_id' => '42', 'parent_id' => 'parent', 'sub' => {'field'=>{'pos'=>15}}}
  end

  def stub_influx(url="http://localhost:8086/db/fluentd/series?p=root&u=root&time_precision=s")
    stub_request(:post, url).with do |req|
      @index_cmds = req.body.split("\n").map {|r| JSON.parse(r) }
    end
  end

  def test_writes_to_default_index
    stub_influx
    driver.configure('fields age,sub.field.pos,_key')
    driver.emit(sample_record)
    driver.run
  end
end
