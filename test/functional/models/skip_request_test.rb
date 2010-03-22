require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class SkipRequestTest < Test::Unit::TestCase

  def test_consider_should_create_a_new_skip_request_when_there_are_none
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    SkipRequest.consider "127.0.0.1", entry
    request = SkipRequest.find(:first)
    assert_equal 1, SkipRequest.count
    assert_equal 'some_location', request.file_location
    assert_equal '127.0.0.1', request.requested_by
  end

  def test_consider_should_not_create_a_new_skip_request_when_there_is_one_from_same_day_and_ip_address
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_location'
    end
    Time.is(Time.parse("Sun Mar 14 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 1, SkipRequest.count
  end

  def test_consider_should_create_a_new_skip_request_when_there_is_one_from_the_same_day_but_different_ip_address
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "192.168.0.5", :file_location => 'some_location'
    end
    Time.is(Time.parse("Sun Mar 14 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 2, SkipRequest.count
  end

  def test_consider_should_create_a_new_skip_request_when_there_is_one_from_the_same_day_and_same_ip_address_but_different_songs
    entry = PlaylistEntry.create! :file_location => 'some_location', :status => PlaylistEntry::PLAYING
    Time.is(Time.parse("Sun Mar 14 12:00:00")) do
      SkipRequest.create! :requested_by => "127.0.0.1", :file_location => 'some_other_location'
    end
    Time.is(Time.parse("Sun Mar 14 12:05:00")) do
      SkipRequest.consider "127.0.0.1", entry
    end
    assert_equal 2, SkipRequest.count
  end
  
  def test_consider_should_purge_old_skip_requests_that_are_not_from_today_and_create_a_new_skip_request
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