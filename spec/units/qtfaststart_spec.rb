require File.dirname(__FILE__) + '/../spec_helper'

module RVideo
  module Tools
  
    describe QtFaststart do
      before do
        setup_qtfaststart_spec
      end
      
      it "should initialize with valid arguments" do
        @qtfaststart.class.should == QtFaststart
      end
      
      it "should have the correct tool_command" do
        @qtfaststart.tool_command.should == 'qt-faststart'
      end
            
      it "should mixin AbstractTool" do
        QtFaststart.included_modules.include?(AbstractTool::InstanceMethods).should be_true
      end
      
      it "should set supported options successfully" do
        @qtfaststart.options[:output_file].should == @options[:output_file]
        @qtfaststart.options[:input_file].should == @options[:input_file]
      end
    end
  end
end

def setup_qtfaststart_spec
  @options = {:input_file => "foo.mp4", :output_file => "foo2.mp4"}
  @command = "qt-faststart $input_file$ $output_file$"
  @qtfaststart = RVideo::Tools::QtFaststart.new(@command, @options)
end