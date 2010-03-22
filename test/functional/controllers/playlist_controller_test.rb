require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class PlaylistControllerTest < ActionController::TestCase
  
  def setup
    @controller = PlaylistController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_get_playlist_renders_successfully
    get :index
    assert_response :success
  end

  def test_get_playlist_renders_the_skip_count
    PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::PLAYING
    SkipRequest.create! :requested_by => "127.0.0.1", :file_location => Test::ExistingFileLocation
    
    get :index
    assert_response :success
    assert_select "p", :text => "This track has 1 skip request(s)"
  end

  def test_should_remove_playlist_entries_when_that_someone_deletes_when_finding_now_playing
    PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::PLAYING
    
    get :index
    assert_nil PlaylistEntry.find_by_file_location(Test::NonExistingFileLocation)
    assert_response :success
  end

  def test_should_remove_playlist_entries_when_that_someone_deletes_when_finding_ready_to_play
    PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::PLAYING
    PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    
    get :index
    assert_nil PlaylistEntry.find_by_file_location(Test::NonExistingFileLocation)
    assert_response :success
  end

  def test_should_not_raise_an_error_when_someone_tries_to_skip_a_track_that_no_longer_exist
    get :skip, :id => 1
    assert_redirected_to playlist_url
  end

  def test_should_not_raise_an_error_when_someone_tries_to_delete_a_track_that_no_longer_exist
    get :delete, :id => 1
    assert_redirected_to playlist_url
  end
    
end