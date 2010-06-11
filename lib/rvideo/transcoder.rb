module RVideo # :nodoc:
  class Transcoder

    attr_reader :executed_commands, :errors, :warnings, :total_time

    #
    # To transcode a video, initialize a Transcoder object:
    #
    #   transcoder = RVideo::Transcoder.new("/path/to/input.mov")
    #
    # Then pass a recipe and valid options to the execute method
    #
    #   recipe = "ffmpeg -i $input_file$ -ar 22050 -ab 64 -f flv -r 29.97 -s"
    #   recipe += " $resolution$ -y $output_file$"
    #   recipe += "\nflvtool2 -U $output_file$"
    #   begin
    #     transcoder.execute(recipe, {:output_file => "/path/to/output.flv",
    #       :resolution => "640x360"})
    #   rescue TranscoderError => e
    #     puts "Unable to transcode file: #{e.class} - #{e.message}"
    #   end
    #
    # If the job succeeds, you can access the metadata of the input and output
    # files with:
    #
    #   transcoder.original     # RVideo::Inspector object
    #   transcoder.processed    # RVideo::Inspector object
    #
    # If the transcoding succeeds, the file may still have problems. RVideo
    # will populate an errors array if the duration of the processed video
    # differs from the duration of the original video, or if the processed
    # file is unreadable.
    #

    def initialize(input_file = nil)
      # Allow a nil input_file for backwards compatibility. (Change at 1.0?)
      check_input_file(input_file)

      @input_file = input_file
      @executed_commands = []
      @errors = []
      @warnings = []
    end

    def original
      @original ||= Inspector.new(:file => @input_file)
    end

    def processed
      if @output_file
        @processed ||= Inspector.new(:file => @output_file)
      else
        nil
      end
    end

    #
    # Requires a command and a hash of various interpolated options. The
    # command should be one or more lines of transcoder tool commands (e.g.
    # ffmpeg, flvtool2). Interpolate options by adding $option_key$ to the
    # recipe, and passing :option_key => "value" in the options hash.
    #
    #   recipe = "ffmpeg -i $input_file$ -ar 22050 -ab 64 -f flv -r 29.97
    #   recipe += "-s $resolution$ -y $output_file$"
    #   recipe += "\nflvtool2 -U $output_file$"
    #
    #   transcoder = RVideo::Transcoder.new("/path/to/input.mov")
    #   begin
    #     transcoder.execute(recipe, {:output_file => "/path/to/output.flv", :resolution => "320x240"})
    #   rescue TranscoderError => e
    #     puts "Unable to transcode file: #{e.class} - #{e.message}"
    #   end
    #

    def execute(task, options = {})
      t1 = Time.now

      if @input_file.nil?
        @input_file = options[:input_file]
      end

      RVideo.logger.info("\nNew transcoder job\n================\nTask: #{task}\nOptions: #{options.inspect}")

      if block_given?
        parse_and_execute(task, options) do |tool, progress|
          yield(tool, progress)
        end
      else
        parse_and_execute(task, options)
      end
      
      if @output_file.nil?
        @output_file = options[:output_file]
      end
      result = check_integrity
      RVideo.logger.info("\nFinished task. Total errors: #{@errors.size}\n")
      @total_time = Time.now - t1
      result
    rescue TranscoderError => e
      raise e
    rescue Exception => e
      handle_unknown_error(e)
    end

    private

    def handle_unknown_error(e)
      RVideo.logger.error "[ERROR] Unhandled RVideo exception: #{e.class} - #{e.message}"
      RVideo.logger.error e.backtrace.join("\n\t")
      raise TranscoderError::UnknownError, "Unexpected RVideo error: #{e.message} (#{e.class})"
    end

    def check_input_file(input_file)
      if input_file and !FileTest.exist?(input_file.gsub("\"",""))
        raise TranscoderError::InputFileNotFound, "File not found (#{input_file})"
      end
    end

    def check_integrity
      precision = 1.1
      if processed.invalid?
        @errors << "Output file invalid"
      elsif (processed.duration >= (original.duration * precision) or processed.duration <= (original.duration / precision))
        @errors << "Original file has a duration of #{original.duration}, but processed file has a duration of #{processed.duration}"
      end
      return @errors.size == 0
    end

    def parse_and_execute(task, options = {})
      raise TranscoderError::ParameterError, "Expected a recipe class (as a string), but got a #{task.class.to_s} (#{task})" unless task.is_a? String
      options = options.merge(:input_file => @input_file)

      commands = task.split(/[\n;]/).compact
      commands_with_progress = number_of_tools_supporting_progress(commands)

      progress_by_tools={}
      commands.each do |c|
        tool = Tools::AbstractTool.assign(c, options)
        tool.original = original

        if block_given?
          tool.execute do |progress|
            progress_by_tools[c.object_id] = progress
            sum = progress_by_tools.values.inject(0) { |s,v| s += v }
            if commands_with_progress > 0
              total_progress = sum / commands_with_progress
              yield(tool, total_progress) if total_progress != @prev_progress
              @prev_progress = total_progress
            end
          end
        else
          tool.execute
        end

        executed_commands << tool
      end
    end
  
  
    def number_of_tools_supporting_progress(commands)
      n = 0
      commands.each do |c|
        tool_name = c.split(" ").first
        n += 1 if RVideo::Tools.const_get(tool_name.underscore.classify).method_defined?(:execute_with_progress)
      end
      n
    end
  
  end
end
