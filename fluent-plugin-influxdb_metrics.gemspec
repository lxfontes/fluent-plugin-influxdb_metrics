$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name          = "fluent-plugin-influxdb_metrics"
  s.version       = `cat VERSION`
  s.authors       = ["lxfontes"]
  s.email         = ["lxfontes+influx@gmail.com"]
  s.description   = %q{InfluxDB output plugin for Fluentd}
  s.summary       = %q{output plugin for fluentd}
  s.homepage      = "https://github.com/lxfontes/fluent-plugin-influxdb_metrics"
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_runtime_dependency "fluentd"
  s.add_runtime_dependency "influxdb", "~> 0.1.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  s.add_development_dependency "test-unit", ">= 3.1.0"
  s.add_development_dependency "minitest", ">= 5.8.0"
end
