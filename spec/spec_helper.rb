require File.dirname(__FILE__) + '/../lib/rvideo'

def ffmpeg(key)
  load_fixture(:ffmpeg_builds)[key.to_s]['response']
end

def files(key)
  load_fixture(:files)[key.to_s]['response']
end

def recipes(key)
  load_fixture(:recipes)[key.to_s]
end

def load_fixture(name)
  YAML.load_file("#{FIXTURE_PATH}/#{name}.yml")
end

def spec_video(name)
  File.expand_path File.join(File.dirname(__FILE__), "files", name)
end

LOG_PATH = File.join(File.dirname(__FILE__), "spec.log")
RVideo::Transcoder.logger = Logger.new LOG_PATH
