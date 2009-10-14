module RVideo
  module Tools
    class Segmenter
      include AbstractTool::InstanceMethods
      
      def tool_command
        'segmenter'
      end
      
      private
      
      def parse_result(result)
        # TODO: parse segmenter results
        return true
      end
      
    end
  end
end
