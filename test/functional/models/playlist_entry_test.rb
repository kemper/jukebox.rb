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

  def test_skip_requests_returns_all_the_skip_requests
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
    skip_request1 = SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_location'
    skip_request2 = SkipRequest.create! :requested_by => "127.0.0.2", :file_location => 'some_location'
    assert_equal 2, entry.skip_requests.size
    assert_true entry.skip_requests.include?(skip_request1)
    assert_true entry.skip_requests.include?(skip_request2)
  end

  def test_can_skip_returns_true_if_there_are_as_many_skip_requests_as_the_jukebox_options
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
    JukeboxOptions::NumberOfRequestsInOrderToSkip.times do |count|
      SkipRequest.create! :requested_by => "127.0.0.#{count}", :file_location => 'some_location'
    end
    assert_true entry.can_skip?
  end

  def test_can_skip_returns_false_if_there_are_not_many_skip_requests_as_the_jukebox_options
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
    (JukeboxOptions::NumberOfRequestsInOrderToSkip - 1).times do |count|
      SkipRequest.create! :requested_by => "127.0.0.#{count}", :file_location => 'some_location'
    end
    assert_false entry.can_skip?
  end

  def test_file_exists_return_true_if_the_file_exists
    entry = PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    assert_true entry.file_exists?
  end

  def test_file_exists_return_false_if_the_file_does_not_exist
    entry = PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    assert_false entry.file_exists?
  end
  
  def test_destroy_non_existent_entries
    PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    PlaylistEntry.destroy_non_existent_entries
    assert_equal 0, PlaylistEntry.find(:all).size
  end
  
end