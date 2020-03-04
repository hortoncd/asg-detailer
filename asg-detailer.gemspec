# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asg-detailer/version'

Gem::Specification.new do |spec|
  spec.name          = "asg-detailer"
  spec.version       = AsgDetailer::VERSION
  spec.authors       = ["Chris Horton"]
  spec.email         = ["hortoncd@gmail.com"]

  spec.summary       = %q{Deatil an existing infrastructure.}
  spec.description   = %q{Produce details of an existing infrastructure built with typical ASG & ELB setup.}
  spec.homepage      = "https://github.com/hortoncd/asg-detailer"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/asg-detailer}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'simplecov', '~> 0.12', '>= 0.12.0'
  spec.add_dependency 'aws-sdk-ec2', '~> 1'
  spec.add_dependency 'aws-sdk-elasticloadbalancing', '~> 1'
  spec.add_dependency 'aws-sdk-autoscaling', '~> 1'
end
