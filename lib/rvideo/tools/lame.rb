module RVideo
  module Tools
    class Lame
      include AbstractTool::InstanceMethods
      attr_reader :raw_metadata
      
      def tool_command
        'lame'
      end
      
      
      def execute_with_progress(&block)
        RVideo.logger.info("\nExecuting Command: #{@command}\n")
        do_execute_with_progress(@command, &block)
      rescue RVideo::CommandExecutor::ProcessHungError
        raise TranscoderError, "Transcoder hung."
      end
      
      def do_execute_with_progress(command,&block)
        @raw_result = ''
        CommandExecutor::execute_with_block(command, "\r") do |line|
          progress = parse_progress(line)
          block.call(progress) if block && progress
          @raw_result += line + "\r"
        end
      end
      
      def parse_progress(line)
        if line =~ /\((\d+)\%\)/
          p = $1
          p = 100 if p && (p.to_i > 100)
        end
        p
      end
      
      
      private
      
      def parse_result(result)
        
        if m = /usage: lame [options] <infile> [outfile]/.match(result)
          raise TranscoderError::InvalidCommand, "usage: lame [options] <infile> [outfile]"
        end
        
        if m = /Warning: unsupported audio format/.match(result)
          raise TranscoderError::InvalidFile, "Warning: unsupported audio format"
        end
        
        if m = /Could not find/.match(result)
          raise TranscoderError::InvalidFile, "No such file or directory"          
        end
        
        @raw_metadata = result.empty? ? "No Results" : result
        return true
      end
      
    end
  end
end