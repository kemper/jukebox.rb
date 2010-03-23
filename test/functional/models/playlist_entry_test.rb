require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class PlaylistEntryTest < Test::Unit::TestCase

  should "find entries ready to play" do
    PlaylistEntry.create! :file_location => 'first', :status => PlaylistEntry::UNPLAYED
    PlaylistEntry.create! :file_location => 'second', :status => PlaylistEntry::UNPLAYED
    
    assert_equal 'first', PlaylistEntry.find_all_ready_to_play.first.file_location
  end

  should "skip request should create a new skip request" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    PlaylistEntry.request_skip("127.0.0.1", entry.id)
    request = SkipRequest.find(:first)
    assert_equal 'some_location', request.file_location
    assert_equal '127.0.0.1', request.requested_by
  end

  should "skip requests returns all the skip requests" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
    skip_request1 = SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_location'
    skip_request2 = SkipRequest.create! :requested_by => "127.0.0.2", :file_location => 'some_location'
    assert_equal 2, entry.skip_requests.size
    assert_true entry.skip_requests.include?(skip_request1)
    assert_true entry.skip_requests.include?(skip_request2)
  end

  should "can skip returns true if there are as many skip requests as the jukebox options" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
    JukeboxOptions::NumberOfRequestsInOrderToSkip.times do |count|
      SkipRequest.create! :requested_by => "127.0.0.#{count}", :file_location => 'some_location'
    end
    assert_true entry.can_skip?
  end

  should "can skip returns false if there are not many skip requests as the jukebox options" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
    (JukeboxOptions::NumberOfRequestsInOrderToSkip - 1).times do |count|
      SkipRequest.create! :requested_by => "127.0.0.#{count}", :file_location => 'some_location'
    end
    assert_false entry.can_skip?
  end

  should "file exists return true if the file exists" do
    entry = PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    assert_true entry.file_exists?
  end

  should "file exists return false if the file does not exist" do
    entry = PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    assert_false entry.file_exists?
  end
  
  should "destroy non existent entries" do
    PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    PlaylistEntry.destroy_non_existent_entries
    assert_equal 0, PlaylistEntry.find(:all).size
  end
  
  should "create random will not create a playlist entry that exists" do
    all_mp3s = Dir.glob(File.join([JUKEBOX_MUSIC_ROOT, "**", "*.mp3"].compact))
    all_mp3s.each do |file_location|
      PlaylistEntry.create! :file_location => file_location, :status => PlaylistEntry::UNPLAYED
    end
    PlaylistEntry.create_random!
    assert_equal all_mp3s.size, PlaylistEntry.find(:all).size
  end

  should "create random will not create a playlist entry that exists when playing more than the number of songs" do
    all_mp3s = Dir.glob(File.join([JUKEBOX_MUSIC_ROOT, "**", "*.mp3"].compact))
    PlaylistEntry.create_random! :number_to_create => all_mp3s.size + 1
    assert_equal all_mp3s.size, PlaylistEntry.find(:all).size
  end
  
end