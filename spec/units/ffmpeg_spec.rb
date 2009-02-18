require File.dirname(__FILE__) + '/../spec_helper'

module RVideo
  module Tools
  
    describe Ffmpeg do
      before do
        setup_ffmpeg_spec
      end
      
      it "should initialize with valid arguments" do
        @ffmpeg.class.should == Ffmpeg
      end
      
      it "should have the correct tool_command" do
        @ffmpeg.tool_command.should == 'ffmpeg'
      end
      
      it "should call parse_result on execute, with a ffmpeg result string" do
        @ffmpeg.should_receive(:parse_result).once.with /\AFFmpeg version/
        @ffmpeg.execute
      end
      
      it "should mixin AbstractTool" do
        Ffmpeg.included_modules.include?(AbstractTool::InstanceMethods).should be_true
      end
      
      it "should set supported options successfully" do
        @ffmpeg.options[:resolution].should == @options[:resolution]
        @ffmpeg.options[:input_file].should == @options[:input_file]
        @ffmpeg.options[:output_file].should == @options[:output_file]
      end
      
    end
    
    describe Ffmpeg, " magic variables" do
      before do
        @options = {
          :input_file => spec_file("kites.mp4"),
          :output_file => "bar"
        }
        
        # mock_inspector = mock("inspector")
        # Inspector.stub!(:new).and_return(mock_inspector)
        # mock_inspector.stub!(:fps).and_return 23.98
        # mock_inspector.stub!(:width).and_return 1280
        # mock_inspector.stub!(:height).and_return 720
      end
      
      it 'should access the original fps (ffmpeg)' do
        ffmpeg = Ffmpeg.new("ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame $original_fps$ -s 320x240 -y $output_file$", @options)
        ffmpeg.command.should == "ffmpeg -i '#{@options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 10.00 -s 320x240 -y '#{@options[:output_file]}'"
      end
      
      it 'should create width/height (ffmpeg)' do
        @options.merge! :width => "640", :height => "360"
        command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
        ffmpeg = Ffmpeg.new(command, @options)
        ffmpeg.command.should == "ffmpeg -i '#{@options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 640x360 -y 'bar'"
      end
      
      it 'should support calculated height' do
        @options.merge! :width => "640"
        command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
        ffmpeg = Ffmpeg.new(command, @options)
        ffmpeg.command.should == "ffmpeg -i '#{@options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 640x528 -y 'bar'"
      end
      
      it 'should support calculated width' do
        @options.merge! :height => "360"
        command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
        ffmpeg = Ffmpeg.new(command, @options)
        ffmpeg.command.should == "ffmpeg -i '#{@options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 448x360 -y 'bar'"
      end
      
      # These appear unsupported..
      # 
      # it 'should support passthrough height' do
      #   options = {:input_file => spec_file("kites.mp4"), :output_file => "bar", :width => "640"}
      #   command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
      #   ffmpeg = Ffmpeg.new(command, options)
      #   ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 640x720 -y 'bar'"        
      # end
      # 
      # it 'should support passthrough width' do
      #   options = {:input_file => spec_file("kites.mp4"), :output_file => "bar", :height => "360"}
      #   command = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 $resolution$ -y $output_file$"
      #   ffmpeg = Ffmpeg.new(command, options)
      #   ffmpeg.command.should == "ffmpeg -i '#{options[:input_file]}' -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s 1280x360 -y 'bar'"        
      # end
    end
    
    describe Ffmpeg, " when parsing a result" do
      before do
        setup_ffmpeg_spec
        
        @result  = ffmpeg_result(:result1)
        @result2 = ffmpeg_result(:result2)
        @result3 = ffmpeg_result(:result3)
        @result4 = ffmpeg_result(:result4)
      end
      
      it "should create correct result metadata" do
        @ffmpeg.send(:parse_result, @result).should be_true
        @ffmpeg.frame.should == '4126'
        @ffmpeg.output_fps.should be_nil
        @ffmpeg.q.should == '31.0'
        @ffmpeg.size.should == '5917kB'
        @ffmpeg.time.should == '69.1'
        @ffmpeg.output_bitrate.should == '702.0kbits/s'
        @ffmpeg.video_size.should == "2417kB"
        @ffmpeg.audio_size.should == "540kB"
        @ffmpeg.header_size.should == "0kB"
        @ffmpeg.overhead.should == "100.140277%"
        @ffmpeg.psnr.should be_nil
      end
      
      it "should create correct result metadata (2)" do
        @ffmpeg.send(:parse_result, @result2).should be_true
        @ffmpeg.frame.should == '584'
        @ffmpeg.output_fps.should be_nil
        @ffmpeg.q.should == '6.0'
        @ffmpeg.size.should == '708kB'
        @ffmpeg.time.should == '19.5'
        @ffmpeg.output_bitrate.should == '297.8kbits/s'
        @ffmpeg.video_size.should == "49kB"
        @ffmpeg.audio_size.should == "153kB"
        @ffmpeg.header_size.should == "0kB"
        @ffmpeg.overhead.should == "250.444444%"
        @ffmpeg.psnr.should be_nil
      end
      
      it "should create correct result metadata (3)" do
        @ffmpeg.send(:parse_result, @result3).should be_true
        @ffmpeg.frame.should == '273'
        @ffmpeg.output_fps.should == "31"
        @ffmpeg.q.should == '10.0'
        @ffmpeg.size.should == '398kB'
        @ffmpeg.time.should == '5.9'
        @ffmpeg.output_bitrate.should == '551.8kbits/s'
        @ffmpeg.video_size.should == "284kB"
        @ffmpeg.audio_size.should == "92kB"
        @ffmpeg.header_size.should == "0kB"
        @ffmpeg.overhead.should == "5.723981%"
        @ffmpeg.psnr.should be_nil
      end
      
      it "should create correct result metadata (4)" do
        @ffmpeg.send(:parse_result, @result4).should be_true
        @ffmpeg.frame.should be_nil
        @ffmpeg.output_fps.should be_nil
        @ffmpeg.q.should be_nil
        @ffmpeg.size.should == '1080kB'
        @ffmpeg.time.should == '69.1'
        @ffmpeg.output_bitrate.should == '128.0kbits'
        @ffmpeg.video_size.should == "0kB"
        @ffmpeg.audio_size.should == "1080kB"
        @ffmpeg.header_size.should == "0kB"
        @ffmpeg.overhead.should == "0.002893%"
        @ffmpeg.psnr.should be_nil
      end
      
      it "ffmpeg should calculate PSNR if it is turned on" do
        @ffmpeg.send(:parse_result, @result.gsub("Lsize=","LPSNR=Y:33.85 U:37.61 V:37.46 *:34.77 size=")).should be_true
        @ffmpeg.psnr.should == "Y:33.85 U:37.61 V:37.46 *:34.77"
      end
    end
    
    context Ffmpeg, "result parsing should raise an exception" do
      setup do
        setup_ffmpeg_spec
        @results = load_fixture :ffmpeg_results
      end
      
      specify "when codec not supported" do
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:amr_nb_not_supported))
        }.should raise_error(TranscoderError::InvalidFile, "Codec amr_nb not supported by this build of ffmpeg")
      end
      
      specify "when not passed a command" do
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:missing_command))
        }.should raise_error(TranscoderError::InvalidCommand, "must pass a command to ffmpeg")
      end
      
      specify "when given a broken command" do
        lambda { 
          @ffmpeg.send(:parse_result, ffmpeg_result(:broken_command))
        }.should raise_error(TranscoderError::InvalidCommand, "Unable for find a suitable output format for 'foo'")
      end
      
      specify "when the output file has no streams" do
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:output_has_no_streams))
        }.should raise_error(TranscoderError, /Output file does not contain.*stream/)
        
      end
      
      specify "when given a missing input file" do
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:missing_input_file))
        }.should raise_error(TranscoderError::InvalidFile, /I\/O error: .+/)
      end
      
      specify "when given a file it can't handle"
      
      specify "when cancelled halfway through"
    
      specify "when receiving unexpected results" do
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:unexpected_results))
        }.should raise_error(TranscoderError::UnexpectedResult, 'foo - bar')
      end
      
      specify "with an unsupported codec" do
        @ffmpeg.original = Inspector.new(:raw_response => files('kites2'))
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:unsupported_codec))
        }.should raise_error(TranscoderError::InvalidFile, /samr/)
      end
      
      specify "when a stream cannot be written" do
        lambda {
          @ffmpeg.send(:parse_result, ffmpeg_result(:unwritable_stream))
        }.should raise_error(TranscoderError, /flv doesnt support.*incorrect codec/)
      end
      
    end
  end
end

def setup_ffmpeg_spec
  @options = {
    :input_file => spec_file("kites.mp4"),
    :output_file => "bar",
    :width => "320", :height => "240"
  }
  @simple_avi = "ffmpeg -i $input_file$ -ar 44100 -ab 64 -vcodec xvid -acodec libmp3lame -r 29.97 -s $resolution$ -y $output_file$"  
  @ffmpeg = RVideo::Tools::Ffmpeg.new(@simple_avi, @options)
end