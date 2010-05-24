module RVideo
  module Tools
    class HandBrakeCLI
      include AbstractTool::InstanceMethods
      attr_reader :raw_metadata
      
      def tool_command
        'HandBrakeCLI'
      end
      
      private
      
      def parse_result(result)
        
        if m = /Syntax: HandBrakeCLI [options] -i <device> -o <file>/.match(result)
          raise TranscoderError::InvalidCommand, "Syntax: HandBrakeCLI [options] -i <device> -o <file>"
        end
                
        if m = /No such file or directory/.match(result)
          raise TranscoderError::InvalidFile, "No such file or directory"          
        end
        
        if m = /Undefined error:/.match(result)
          raise TranscoderError::UnexpectedResult, "Undefined error"
        end

        @raw_metadata = result.empty? ? "No Results" : result
        return true
      end
      
      def do_execute_with_progress(command,&block)
        @raw_result = ''
        CommandExecutor::execute_with_block(command, "\r") do |line|
          progress = parse_progress(line)
          block.call(progress) if block
          @raw_result += line + "\r"            
        end
      end
      
      def execute_with_progress(&block)
        RVideo.logger.info("\nExecuting Command: #{@command}\n")
        do_execute_with_progress(@command, &block)
      rescue RVideo::CommandExecutor::ProcessHungError
        raise TranscoderError, "Transcoder hung."
      end
      
      def parse_progress(line)
        if /Encoding: task (\d) of (\d), (\d{1,3}\.\d{1,2}) \%/
          p = $3.to_i
        end

        p = 100 if p > 100        
        return p || 0
      end
      
    end
  end
end
