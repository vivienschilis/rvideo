module RVideo
  module Tools
    class Ffmpeg2theora
      include AbstractTool::InstanceMethods

      attr_reader :raw_metadata

      def tool_command
        'ffmpeg2theora'
      end

      def do_execute_with_progress(command, &block)
        @raw_result = ''
        duration = 0
        CommandExecutor::execute_with_block(command, "\r") do |line|
          progress, duration = parse_progress(line, duration)
          block.call(progress) if block && progress
          @raw_result += line.to_s + "\r"
        end
      end
      
      def execute_with_progress(&block)
        RVideo.logger.info("\nExecuting Command: #{@command}\n")
        do_execute_with_progress(@command, &block)
      rescue RVideo::CommandExecutor::ProcessHungError
        raise TranscoderError, "Transcoder hung."
      end
      
      def parse_progress(line, duration)
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/
          duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
        end

        if line =~ /(\d{1,2}):(\d{2}):(\d{2})\.(\d)\d audio: \d+kbps video: \d+kbps/
          current_time = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
        end
        
        progress = (current_time*100/duration) rescue nil
        return [progress, duration]
      end

      def format_video_quality(params={})
        bitrate = params[:video_bit_rate].blank? ? nil : params[:video_bit_rate]
        factor = (params[:scale][:width].to_f * params[:scale][:height].to_f * params[:fps].to_f)
        case params[:video_quality]
        when 'low'
          " -v 1 "
        when 'medium'
          "-v 5 "
        when 'high'
          "-v 10 "
        else
          ""
        end
      end  

      def parse_result(result)
        if m = /does not exist or has an unknown data format/.match(result)
          raise TranscoderError::InvalidFile, "I/O error"
        end
        
        if m = /General output options/.match(result)
          raise TranscoderError::InvalidCommand, "no command passed to ffmpeg2theora, or no output file specified"
        end
        
        @raw_metadata = result.empty? ? "No Results" : result
        return true
      end

    end
  end
end
