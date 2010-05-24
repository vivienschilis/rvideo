require File.dirname(__FILE__) + '/../spec_helper'

module RVideo
  module Tools
  
    describe HandBrakeCLI do
      before do
        setup_hbcli_spec
      end
      
      it "should initialize with valid arguments" do
        @hbcli.class.should == HandBrakeCLI
      end
      
      it "should have the correct tool_command" do
        @hbcli.tool_command.should == 'HandBrakeCLI'
      end
            
      it "should mixin AbstractTool" do
        HandBrakeCLI.included_modules.include?(AbstractTool::InstanceMethods).should be_true
      end
      
      it "should set supported options successfully" do
        @hbcli.options[:output_file].should == @options[:output_file]
        @hbcli.options[:input_file].should == @options[:input_file]
      end
      
      it "should execute execute_with_progress" do
        @hbcli.execute_with_progress
      end
      
    end
  end
end

def setup_hbcli_spec
  @options = {:input_file => "foo.mp4", :output_file => "foo2.mp4"}
  @command = "HandBrake -i $input_file$ -o $output_file$"
  @hbcli = RVideo::Tools::HandBrakeCLI.new(@command, @options)
end