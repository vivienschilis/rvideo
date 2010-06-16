module RVideo
  module Tools
    class Segmenter
      include AbstractTool::InstanceMethods
      
      attr_reader :raw_metadata
      
      def tool_command
        'segmenter'
      end
      
      private
      
      def parse_result(result)
        if m = /Could not write mpegts header to first output file/.match(result)
          raise TranscoderError::InvalidFile
        end
        
        if m = /Usage: segmenter <input MPEG-TS file> <segment duration in seconds> <output MPEG-TS file prefix> <output m3u8 index file> <http prefix>/.match(result)
          raise TranscoderError::InvalidCommand, "Usage: segmenter <input MPEG-TS file> <segment duration in seconds> <output MPEG-TS file prefix> <output m3u8 index file> <http prefix>"
        end
        
        # TODO: parse segmenter results
        return true
      end
      
    end
  end
end
