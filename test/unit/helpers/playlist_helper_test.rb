require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

class PlaylistHelperTest < Test::Unit::TestCase

  context "now_playing" do
    should "return playlist entry now playing" do
      PlaylistEntry.expects(:find_by_status).with(PlaylistEntry::PLAYING).returns(:now_playing)
      assert_equal :now_playing, class_for(:playlist_helper).new.now_playing
    end
  end
  
  context "ready_to_play" do
    should "return playlist entries ready to play" do
      PlaylistEntry.expects(:find_all_ready_to_play).returns(:ready_to_play)
      assert_equal :ready_to_play, class_for(:playlist_helper).new.ready_to_play
    end
  end
  
end