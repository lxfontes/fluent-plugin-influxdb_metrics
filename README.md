# InfluxDB-Metrics, a plugin for [Fluentd](http://fluentd.org)

Feeding time series data to InfluxDB via FluentD.

## Installation

    $ gem install fluent-plugin-influxdb_metrics

## Usage

    type influxdb_metrics
    host influx.local
    port 8086
    dbname test
    table metrics
    user testuser
    password mypwd
    fields event_type,event_name,event_data.sub.value,event_data.sub.other_value

