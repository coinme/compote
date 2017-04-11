# coding: utf-8

lib = File.expand_path '../lib', __FILE__
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require 'compote/version'


Gem::Specification.new do | spec |

  spec.name          = 'compote'
  spec.version       = Compote::VERSION
  spec.authors       = [ 'Dmitry Maganov' ]
  spec.email         = [ 'vonagam@gmail.com' ]

  spec.summary       = 'Wrapper for docker-compose with additional features.'
  spec.homepage      = 'https://github.com/vonagam/compote'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split( "\x0" ).reject { | path | path.match %r{^spec/} }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep( %r{^exe/} ) { | path | File.basename path }
  spec.require_paths = [ 'lib' ]


  spec.add_dependency 'thor', '~> 0.19' # cli builder - erikhuda/thor
  spec.add_dependency 'json-schema', '~> 2.8' # json scheme validator - ruby-json-schema/json-schema
  spec.add_dependency 'dotenv', '~> 2.2' # env variables from .env file - bkeepers/dotenv

  spec.add_development_dependency 'bundler', '~> 1.14' # dependencies manager - bundler/bundler
  spec.add_development_dependency 'rake', '~> 12.0' # tasks runner - ruby/rake
  spec.add_development_dependency 'rspec', '~> 3.0' # test framework - rspec/rspec
  spec.add_development_dependency 'aruba', '~> 0.14' # test framework - rspec/rspec

  spec.add_development_dependency 'pry', '~> 0' # debug console - pry/pry
  spec.add_development_dependency 'pry-rescue', '~> 0' # start debug on exception - conradirwin/pry-rescue
  spec.add_development_dependency 'pry-stack_explorer', '~> 0' # moving in stack vertically - pry/pry-stack_explorer
  spec.add_development_dependency 'pry-byebug', '~> 0' # moving in stack forward - deivid-rodriguez/pry-byebug
  spec.add_development_dependency 'pry-inline', '~> 0' # view variables values inline - seikichi/pry-inline
  spec.add_development_dependency 'pry-state', '~> 0' # view variables values - sudhagars/pry-state
  spec.add_development_dependency 'pry-doc', '~> 0' # view ruby core classes documentation - pry/pry-doc

end
