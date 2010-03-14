class SkipRequest < ActiveRecord::Base

  def self.consider ip_address, playlist_entry
    unless request_already_made?(ip_address, playlist_entry)
      SkipRequest.create! :requested_by => ip_address, :file_location => playlist_entry.file_location
    end
  end
  
  def self.request_already_made?(ip_address, playlist_entry)
    previous_request = SkipRequest.find_by_requested_by_and_file_location ip_address, playlist_entry.file_location
    return false unless previous_request
    previous_request.made_today?
  end
  
  def made_today?
    self.updated_at.at_beginning_of_day == Time.now.at_beginning_of_day
  end
  
end
