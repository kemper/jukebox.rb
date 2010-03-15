require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class PlaylistEntryTest < Test::Unit::TestCase

  def test_find_entries_ready_to_play
    PlaylistEntry.create! :file_location => 'first', :status => PlaylistEntry::UNPLAYED
    PlaylistEntry.create! :file_location => 'second', :status => PlaylistEntry::UNPLAYED
    
    assert_equal 'first', PlaylistEntry.find_all_ready_to_play.first.file_location
  end

  def test_skip_request_should_create_a_new_skip_request
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    PlaylistEntry.request_skip("127.0.0.1", entry.id)
    request = SkipRequest.find(:first)
    assert_equal 'some_location', request.file_location
    assert_equal '127.0.0.1', request.requested_by
  end
  
end