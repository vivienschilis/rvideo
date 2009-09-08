require 'lib/rvideo'

transcoder = RVideo::Transcoder.new

recipe = "ffmpeg -i $input_file$ -ar 22050 -ab 64 -f flv -y $output_file$"
recipe += "\nflvtool2 -U $output_file$"
begin
  transcoder.execute(recipe, {:input_file => "tmp/broken.avi",
    :output_file => "tmp/output.flv", :progress => true}) do |progress|
    puts "#{progress[:tool].tool_command}: #{progress[:progress]}%"
  end
rescue RVideo::TranscoderError => e
  puts "Unable to transcode file: #{e.class} - #{e.message}"
end