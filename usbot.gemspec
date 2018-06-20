# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = "usbot"
  spec.version = '1.0'
  spec.license = "MIT"

  spec.authors = ["John Doe"]
  spec.email = ["johndoe@mail.com"]

  spec.summary = %q{US Consular BOT that scrap available appointment dates}

  spec.files = ['lib/usbot.rb']
  spec.executables = ['usbot.rb']
  spec.require_paths = ["lib"]
end
