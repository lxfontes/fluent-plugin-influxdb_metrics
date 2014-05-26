# encoding: utf-8
require 'date'
require 'influxdb'

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

  def influx_client
    @influxdb ||= InfluxDB::Client.new(@dbname, host: @host,
                                                 port: @port,
                                                 username: @user,
                                                 password: @password)
    @influxdb
  end

  def write(chunk)
    bulk = []

    chunk.msgpack_each do |tag, time, record|
      formatted_record = format_record(tag, time, record)
      bulk << formatted_record if formatted_record
    end

    influx_client.write_point(@table, bulk, false, 's')
  end

  def format_record(tag, time, record)
    metric = {time: time}

    filter_keys.each do |field|
      field_scored = field.gsub('.', '_')
      path = field.split('.')
      rec_pos = record[path.shift]
      path.each do |p|
        rec_pos = rec_pos[p] if rec_pos
      end

      if rec_pos
        metric[field_scored] = rec_pos
      end
    end

    return metric if metric.keys.length > 1
    nil
  end
end
