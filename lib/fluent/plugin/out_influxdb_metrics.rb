# encoding: utf-8
require 'date'
require 'net/http'

class Fluent::InfluxdbMetricsOutput < Fluent::BufferedOutput
  Fluent::Plugin.register_output('influxdb_metrics', self)

  config_param :host, :string,  :default => 'localhost'
  config_param :port, :integer,  :default => 8086
  config_param :user, :string,  :default => 'root'
  config_param :password, :string,  :default => 'root'
  config_param :dbname, :string,  :default => 'fluentd'
  config_param :table, :string, :default => 'metrics'
  config_param :fields, :string, :default => ''

  def initialize
    super
  end

  def configure(conf)
    super
  end

  def start
    super
  end

  def filter_keys
    @filter_keys ||= @fields.split(',').map(&:strip)
    @filter_keys
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def shutdown
    super
  end

  def write(chunk)
    bulk = []

    chunk.msgpack_each do |tag, time, record|
      formatted_record = format_record(tag, time, record)
      bulk << formatted_record if formatted_record
    end

    http = Net::HTTP.new(@host, @port)
    resp, _ = http.post("/db/#{@dbname}/series?u=#{@user}&p=#{@password}&time_precision=s",
                           Yajl::Encoder.encode(bulk) + "\n",
                           'Content-Type' => 'text/json')
    resp.value
  end

  def format_record(tag, time, record)
    cols = ['time']
    points = [time]

    filter_keys.each do |field|
      path = field.split('.')
      rec_pos = record[path.shift]
      path.each do |p|
        rec_pos = rec_pos[p] if rec_pos
      end

      if rec_pos
        cols << field
        points << rec_pos
      end
    end

    if cols.length > 1
      return {
        name: @table,
        columns: cols,
        points: [points]
      }
    end

    nil
  end
end
