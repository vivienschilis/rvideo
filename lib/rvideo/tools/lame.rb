module RVideo
  module Tools
    class Lame
      include AbstractTool::InstanceMethods
      attr_reader :raw_metadata
      
      def tool_command
        'lame'
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