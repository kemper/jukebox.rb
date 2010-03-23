require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class SkipRequestTest < Test::Unit::TestCase

  should "consider should create a new skip request when there are none" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    SkipRequest.consider "127.0.0.1", entry
    request = SkipRequest.find(:first)
    assert_equal 1, SkipRequest.count
    assert_equal 'some_location', request.file_location
    assert_equal '127.0.0.1', request.requested_by
  end

  should "consider should not create a new skip request when there is one from same day and ip address" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_location'
    end
    Time.is(Time.parse("Sun Mar 14 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 1, SkipRequest.count
  end

  should "consider should create a new skip request when there is one from the same day but different ip address" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "192.168.0.5", :file_location => 'some_location'
    end
    Time.is(Time.parse("Sun Mar 14 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 2, SkipRequest.count
  end

  should "consider should create a new skip request when there is one from the same day and same ip address but different songs" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_other_location'
    end
    Time.is(Time.parse("Sun Mar 14 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 2, SkipRequest.count
  end
  
  should "consider should purge old skip requests that are not from today and create a new skip request" do
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_other_location'
    end
    Time.is(Time.parse("Sun Mar 15 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 1, SkipRequest.count
    assert_equal Time.parse("Sun Mar 15 12:05:00").day, SkipRequest.find(:first).created_at.day
  end
  
end