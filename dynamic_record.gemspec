# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamic/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamic_record"
  spec.version       = DynamicRecord::VERSION
  spec.authors       = ["Lionel Chauvin"]
  spec.email         = ["megabigbug@yahoo.fr"]

  spec.summary       = %q{An ActiveRecord extension that dynamically creates classes}
  spec.description   = %q{An ActiveRecord extension that dynamically creates classes}
  spec.homepage      = ""

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner"

  spec.add_development_dependency "sqlite3"

  spec.add_dependency "activerecord", ">= 5.0"
  spec.add_dependency "globalize", ">= 5.1.0.beta1"
  spec.add_dependency "activemodel-serializers-xml", ">= 1.0.1"
  spec.add_dependency "globalize-accessors"
  spec.add_dependency "acts_as_permalink"
  spec.add_dependency "paranoia", ">= 2.2.0"
  spec.add_dependency "paper_trail", ">= 7.0.0"

end
