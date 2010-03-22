require 'id3'

class PlaylistEntry < ActiveRecord::Base
  UNPLAYED = "unplayed"
  PLAYING = "playing"

  class << self
    def playing_track
      find_by_status(PlaylistEntry::PLAYING)
    end
  
    def find_ready_to_play
      find(:first, :conditions => {:status => UNPLAYED}, :order => :id)
    end

    def find_all_ready_to_play
      find(:all, :conditions => {:status => UNPLAYED}, :order => :id)
    end

    def find_next_track_to_play
      track = find_ready_to_play
      return track unless track.nil?
      return false unless PlayerStatus.continuous_play?
      create_random!
      find_ready_to_play
    end

    def create_random!(params = {})
      mp3_files = Dir.glob(File.join([JUKEBOX_MUSIC_ROOT, params[:user], "**", "*.mp3"].compact))
      return if mp3_files.empty?

      srand(Time.now.to_i)
      (params[:number_to_create] || 1).to_i.times do
        create! :file_location => mp3_files[rand(mp3_files.size)]
      end
    end
        
    def request_skip(ip_address, track_id)
      playlist_entry = find(track_id)
      SkipRequest.consider(ip_address, playlist_entry)
      if playlist_entry.can_skip?
        playlist_entry.update_attributes! :skip => true
      end
    end
    
    def destroy_non_existent_entries
      find(:all).each do |playlist_entry|
        playlist_entry.destroy if !playlist_entry.file_exists?
      end
    end
  end

  def can_skip?
    skip_requests.size >= JukeboxOptions::NumberOfRequestsInOrderToSkip
  end
  
  def skip_requests
    SkipRequest.find_all_by_file_location(file_location)
  end
  
  def filename
    self.file_location.split('/').last
  end

  def file_exists?
    File.exists? file_location
  end

  begin # ID3 Tag Methods
    def id3
      @id3 ||= ID3::AudioFile.new(file_location)
    end
  
    def title
      id3.tagID3v2['TITLE']['text'] if id3.tagID3v2 && id3.tagID3v2['TITLE']
    end

    def artist
      id3.tagID3v2['ARTIST']['text'] if id3.tagID3v2 && id3.tagID3v2['ARTIST']
    end

    def album
      id3.tagID3v2['ALBUM']['text'] if id3.tagID3v2 && id3.tagID3v2['ALBUM']
    end

    def track_number
      id3.tagID3v2['TRACKNUM']['text'] if id3.tagID3v2 && id3.tagID3v2['TRACKNUM']
    end
  
    def to_s
      "#{artist} - #{title} (#{album})"
    end
  end
  
end
