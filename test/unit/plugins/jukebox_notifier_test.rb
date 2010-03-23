require File.expand_path(File.dirname(__FILE__) +  '/../unit_test_helper')
require 'jukebox_notifier'

class JukeboxNotifierTest < Test::Unit::TestCase
  MOCK_HOST = "http://mock.host:port/ci"
  
  context "jukebox notifier" do
    setup do
      @notifier = JukeboxNotifier.new
      @notifier.jukeboxes = [ MOCK_HOST ]
    end
  
    should "default_jukebox is empty array if no shared settings detected" do
      assert_equal nil, JukeboxNotifier.default_jukebox
    end
  
    should "default_jukebox is default jukebox in an array if set" do
      JukeboxNotifier.stubs(:shared_settings).returns("default_jukebox" => :jukebox_app_url)
      assert_equal :jukebox_app_url, JukeboxNotifier.default_jukebox
    end
  
    should "initialize create jukebox notifier logger" do
      Logger.expects(:new).with("#{RAILS_ROOT}/log/jukebox_notifier.log")
      JukeboxNotifier.new
    end
  
    should "initialize assigns new logger to logger instance variable" do
      Logger.expects(:new).returns(:a_logger)
      assert_equal :a_logger, JukeboxNotifier.new.logger
    end
  
    should "log Net HTTP get_reponse errors" do
      Net::HTTP.stubs(:get_response).raises(Exception)
      jukebox_notifier = JukeboxNotifier.new
      logger = stub
      logger.expects(:error)
      jukebox_notifier.stubs(:logger).returns(logger)
      jukebox_notifier.jukeboxes = ["a jukebox"]
      jukebox_notifier.build_started(nil)
    end

    should "have only the default host if none is specified" do
      JukeboxNotifier.stubs(:default_jukebox).returns(:another_host)
      notifier = JukeboxNotifier.new
      assert_equal [:another_host], notifier.jukeboxes
    end
  
    should "have an initially empty array if no default is specified" do
      JukeboxNotifier.stubs(:default_jukebox).returns(nil)
      notifier = JukeboxNotifier.new
      assert_equal [], notifier.jukeboxes
    end
    
    should "build started" do
      build = stub_everything()
      URI.expects(:parse).with(MOCK_HOST + "/hammertime/add_for/build_started").returns(:uri)
      Net::HTTP.expects(:get_response).with(:uri)
      @notifier.build_started build
    end
  
    should "build successful" do
      build = stub_everything(:successful? => true)
      URI.expects(:parse).with(MOCK_HOST + "/hammertime/add_for/build_successful").returns(:uri)
      Net::HTTP.expects(:get_response).with(:uri)
    
      @notifier.build_finished build
    end
  
    should "build failed" do
      build = stub_everything(:successful? => false)
      URI.expects(:parse).with(MOCK_HOST + "/hammertime/add_for/build_failed").returns(:uri)
      Net::HTTP.expects(:get_response).with(:uri)
    
      @notifier.build_finished build
    end
  end
end