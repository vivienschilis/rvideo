$LOAD_PATH.unshift File.dirname(__FILE__) + '/rvideo'

# core extensions
require 'float'
require 'string'

# gems
require 'rubygems'
require 'active_support'

# rvideo
require 'inspector'
require 'errors'
require 'transcoder'
require 'tools/abstract_tool'
require 'tools/ffmpeg'
require 'tools/mencoder'
require 'tools/flvtool2'
require 'tools/mp4box'
require 'tools/mplayer'
require 'tools/mp4creator'
require 'tools/ffmpeg2theora'
require 'tools/yamdi'

TEMP_PATH      = File.expand_path(File.dirname(__FILE__) + '/../tmp')
REPORT_PATH    = File.expand_path(File.dirname(__FILE__) + '/../report')
