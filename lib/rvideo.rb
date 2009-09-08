$LOAD_PATH.unshift File.dirname(__FILE__)

# core extensions
require 'rvideo/float'
require 'rvideo/string'

# gems
require 'rubygems'
require 'active_support'
require 'open4'

# rvideo
require 'rvideo/inspector'
require 'rvideo/frame_capturer'
require 'rvideo/errors'
require 'rvideo/transcoder'
require 'rvideo/tools/abstract_tool'
require 'rvideo/tools/ffmpeg'
require 'rvideo/tools/mencoder'
require 'rvideo/tools/flvtool2'
require 'rvideo/tools/mp4box'
require 'rvideo/tools/mplayer'
require 'rvideo/tools/mp4creator'
require 'rvideo/tools/ffmpeg2theora'
require 'rvideo/tools/yamdi'
require 'rvideo/tools/qtfaststart'

TEMP_PATH   = File.expand_path(File.dirname(__FILE__) + '/../tmp')
REPORT_PATH = File.expand_path(File.dirname(__FILE__) + '/../report')

module RVideo
  # Configure logging. Assumes that the logger object has an 
  # interface similar to stdlib's Logger class.
  #   
  #   RVideo.logger = Logger.new(STDOUT)
  #
  def self.logger=(logger)
    @logger = logger
  end
  
  def self.logger
    @logger = Logger.new("/dev/null") unless @logger
    @logger
  end
end
