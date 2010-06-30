require File.dirname(__FILE__) + '/../spec_helper'

module RVideo
  module Tools
  
    describe Lame do
      before do
        setup_lame_spec
      end
      
      it "should initialize with valid arguments" do
        @lame.class.should == Lame
      end
      
      it "should have the correct tool_command" do
        @lame.tool_command.should == 'lame'
      end
            
      it "should mixin AbstractTool" do
        Lame.included_modules.include?(AbstractTool::InstanceMethods).should be_true
      end
      
      it "should set supported options successfully" do
        @lame.options[:output_file].should == @options[:output_file]
        @lame.options[:input_file].should == @options[:input_file]
      end
    end
  end
end

def setup_lame_spec
  @options = {:input_file => "foo.mp4", :output_file => "foo2.mp4"}
  @command = "lame $input_file$ $output_file$"
  @lame = RVideo::Tools::Lame.new(@command, @options)
end