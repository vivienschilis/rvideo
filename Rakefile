require "rubygems"
require "fileutils"
require "echoe"

begin
  require "spec/rake/spectask"
rescue LoadError
  puts "To use rspec for testing you must install rspec gem:"
  puts "$ sudo gem install rspec"
  exit
end

__HERE__ = File.dirname(__FILE__)
require File.join(__HERE__, 'lib', 'rvideo', 'version')
require File.join(__HERE__, 'lib', 'rvideo')

###

AUTHOR = [
  "Jonathan Dahl (Slantwise Design)",
  "Seth Thomas Rasmussen"
]
EMAIL       = "jon@slantwisedesign.com"
DESCRIPTION = "Inspect and transcode video and audio files."

NAME = "rvideo"

REV    = `git log -n1 --pretty=oneline | cut -d' ' -f1`.strip
BRANCH = `git branch | grep '*' | cut -d' ' -f2`.strip

VERS = "#{RVideo::VERSION::STRING} (#{BRANCH} @ #{REV})"

Echoe.new NAME do |p|
  p.author      = AUTHOR 
  p.description = DESCRIPTION
  p.email       = EMAIL
  p.summary     = DESCRIPTION
  p.url         = "http://github.com/greatseth/rvideo"
  
  p.runtime_dependencies     = ["activesupport"]
  p.development_dependencies = ["rspec"]
  
  p.rdoc_options = [
    "--quiet",
    "--title", "rvideo documentation",
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"
  ]
end

# Load supporting Rake files
Dir[File.dirname(__FILE__) + "/tasks/*.rake"].each { |t| load t }

# Echo defines the :default task to run the :test task
task :test => :spec

puts "#{NAME} #{VERS}"
