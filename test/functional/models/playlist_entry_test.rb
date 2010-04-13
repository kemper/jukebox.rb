require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class PlaylistEntryTest < Test::Unit::TestCase
  
  context "find_all_ready_to_play" do
    should "find entries ready to play" do
      PlaylistEntry.create! :file_location => 'first', :status => PlaylistEntry::UNPLAYED
      PlaylistEntry.create! :file_location => 'second', :status => PlaylistEntry::UNPLAYED
    
      assert_equal 'first', PlaylistEntry.find_all_ready_to_play.first.file_location
    end
  end

  context "request_skip" do
    should "create a new skip request" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      PlaylistEntry.request_skip("127.0.0.1", entry.id)
      request = SkipRequest.find(:first)
      assert_equal 'some_location', request.file_location
      assert_equal '127.0.0.1', request.requested_by
    end
  end
  
  context "skip_requests" do
    should "return all the skip requests" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
      skip_request1 = SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_location'
      skip_request2 = SkipRequest.create! :requested_by => "127.0.0.2", :file_location => 'some_location'
      assert_equal 2, entry.skip_requests.size
      assert_true entry.skip_requests.include?(skip_request1)
      assert_true entry.skip_requests.include?(skip_request2)
    end
  end

  context "can_skip" do
    should "return true if there are as many skip requests as the jukebox options" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
      JukeboxOptions::NumberOfRequestsInOrderToSkip.times do |count|
        SkipRequest.create! :requested_by => "127.0.0.#{count}", :file_location => 'some_location'
      end
      assert_true entry.can_skip?
    end

    should "return false if there are not many skip requests as the jukebox options" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::UNPLAYED
      (JukeboxOptions::NumberOfRequestsInOrderToSkip - 1).times do |count|
        SkipRequest.create! :requested_by => "127.0.0.#{count}", :file_location => 'some_location'
      end
      assert_false entry.can_skip?
    end
  end

  context "file_exists" do
    should "return true if the file exists" do
      entry = PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::UNPLAYED
      assert_true entry.file_exists?
    end

    should "return false if the file does not exist" do
      entry = PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
      assert_false entry.file_exists?
    end
  end
  
  context "destroy non existent entries" do
    should "destroy entries that have file locations that don't point to a file" do
      PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
      PlaylistEntry.destroy_non_existent_entries
      assert_equal 0, PlaylistEntry.find(:all).size
    end
  end
  
  context "count_likes" do
    should "count the number of feedback entries that have been liked" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Dislike
      Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Hate
      3.times do
        Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Like
      end
      
      assert_equal 3, entry.count_likes
    end
  end
  
  context "count_dislikes" do
    should "count the number of feedback entries that have been disliked" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Hate
      Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Like
      5.times do
        Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Dislike
      end
      
      assert_equal 5, entry.count_dislikes
    end
  end
  
  context "count_hates" do
    should "count the number of feedback entries that have been hated" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Dislike
      Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Like
      7.times do
        Feedback.create! :from => "127.0.0.1", :file_location => 'some_location', :verb => Feedback::Hate
      end
      
      assert_equal 7, entry.count_hates
    end
  end
  
  context "create_random" do
    should "not create a playlist entry that exists" do
      all_mp3s = Dir.glob(File.join([JUKEBOX_MUSIC_ROOT, "**", "*.mp3"].compact))
      all_mp3s.each do |file_location|
        PlaylistEntry.create! :file_location => file_location, :status => PlaylistEntry::UNPLAYED
      end
      PlaylistEntry.create_random!
      assert_equal all_mp3s.size, PlaylistEntry.find(:all).size
    end

    should "not create a playlist entry that exists when playing more than the number of songs" do
      all_mp3s = Dir.glob(File.join([JUKEBOX_MUSIC_ROOT, "**", "*.mp3"].compact))
      PlaylistEntry.create_random! :number_to_create => all_mp3s.size + 1
      assert_equal all_mp3s.size, PlaylistEntry.find(:all).size
    end
  end

  context "feedback" do
    should "save a feedback entry with type 'Like' for the given id" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      PlaylistEntry.like("127.0.0.1", entry.id)
      feedback = Feedback.find(:first)
      assert_equal 'some_location', feedback.file_location
      assert_equal '127.0.0.1', feedback.from
      assert_equal Feedback::Like, feedback.verb
    end

    should "save a feedback entry with type 'Disike' for the given id" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      PlaylistEntry.dislike("127.0.0.1", entry.id)
      feedback = Feedback.find(:first)
      assert_equal 'some_location', feedback.file_location
      assert_equal '127.0.0.1', feedback.from
      assert_equal Feedback::Dislike, feedback.verb
    end

    should "save a feedback entry with type 'Hate' for the given id" do
      entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
      PlaylistEntry.hate("127.0.0.1", entry.id)
      feedback = Feedback.find(:first)
      assert_equal 'some_location', feedback.file_location
      assert_equal '127.0.0.1', feedback.from
      assert_equal Feedback::Hate, feedback.verb
    end
  end

end