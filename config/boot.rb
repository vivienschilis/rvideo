# I don't know what this file was intended for originally, but I've been 
# using it to setup RVideo to play with in an IRB session. - Seth

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),'..', 'lib'))
require 'rvideo'
include RVideo
