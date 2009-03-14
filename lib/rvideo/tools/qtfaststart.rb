module RVideo
  module Tools
    class QtFaststart
      include AbstractTool::InstanceMethods
      attr_reader :raw_metadata
      
      def tool_command
        'qt-faststart'
      end
      
      private
      
      def parse_result(result)
        
        if m = /Usage: qt-faststart <infile.mov> <outfile.mov>/.match(result)
          raise TranscoderError::InvalidCommand, "Usage: qt-faststart <infile.mov> <outfile.mov>"
        end
        
        if m = /last atom in file was not a moov atom/.match(result)
          raise TranscoderError::InvalidFile, "Could not find moov atom"
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
      
    end
  end
end
