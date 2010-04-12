require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class PlaylistControllerTest < ActionController::TestCase

  context "playlist controller" do
    setup do
      @controller = PlaylistController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
    end

    context "index" do
  
      should "render successfully" do
        get :index
        assert_response :success
      end

      should "render 'now playing' entry with like link, dislike link, and hate link" do
        entry1 = PlaylistEntry.create! :file_location => Test::FirstTestTrack, :status => PlaylistEntry::PLAYING

        get :index
        assert_response :success
        assert_select "a[href=?]", playlist_like_url(:id => entry1.id)
        assert_select "a[href=?]", playlist_dislike_url(:id => entry1.id)
        assert_select "a[href=?]", playlist_hate_url(:id => entry1.id)
      end

      should "render the skip count" do
        PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::PLAYING
        SkipRequest.create! :requested_by => "127.0.0.1", :file_location => Test::ExistingFileLocation
    
        get :index
        assert_response :success
        assert_select "p", :text => "This track has 1 skip request(s)"
      end

      should "remove playlist entries when that someone deletes when finding now playing" do
        PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::PLAYING
    
        get :index
        assert_nil PlaylistEntry.find_by_file_location(Test::NonExistingFileLocation)
        assert_response :success
      end

      should "remove playlist entries when that someone deletes when finding ready to play" do
        PlaylistEntry.create! :file_location => Test::ExistingFileLocation, :status => PlaylistEntry::PLAYING
        PlaylistEntry.create! :file_location => Test::NonExistingFileLocation, :status => PlaylistEntry::UNPLAYED
    
        get :index
        assert_nil PlaylistEntry.find_by_file_location(Test::NonExistingFileLocation)
        assert_response :success
      end
    end
  
    context "skip" do
      should "not raise an error when someone tries to skip a track that no longer exist" do
        get :skip, :id => 1
        assert_redirected_to playlist_url
      end
    end
    
    context "delete" do
      should "not raise an error when someone tries to delete a track that no longer exist" do
        get :delete, :id => 1
        assert_redirected_to playlist_url
      end
    end
   
    context "like" do
      should "not raise an error when someone clicks the link and the track no longer exists" do
        get :like, :id => 1
        assert_redirected_to playlist_url
      end
      
      should "create a 'like' feedback entry for the track" do
        entry = PlaylistEntry.create! :file_location => Test::FirstTestTrack, :status => PlaylistEntry::PLAYING
        
        get :like, :id => entry.id
        assert_not_nil Feedback.find_by_file_location(Test::FirstTestTrack)
      end
    end
    
    context "dislike" do
      should "not raise an error when someone clicks the link and the track no longer exists" do
        get :dislike, :id => 1
        assert_redirected_to playlist_url
      end
      
    end
    
    context "hate" do
      should "not raise an error when someone clicks the link and the track no longer exists" do
        get :hate, :id => 1
        assert_redirected_to playlist_url
      end
      
    end
  end
end