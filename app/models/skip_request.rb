class SkipRequest < ActiveRecord::Base

  class << self
    def consider(ip_address, playlist_entry)
      purge_skip_requests_made_before_today
      unless request_already_made?(ip_address, playlist_entry)
        SkipRequest.create! :requested_by => ip_address, :file_location => playlist_entry.file_location
      end
    end

    def purge_skip_requests_made_before_today
      not_made_today = find(:all).select {|request| !request.made_today?}
      not_made_today.each(&:destroy)
    end

    def request_already_made?(ip_address, playlist_entry)
      !find_by_requested_by_and_file_location(ip_address, playlist_entry.file_location).nil?
    end
    
  end
  
  def made_today?
    self.updated_at.at_beginning_of_day == Time.now.at_beginning_of_day
  end
  
end
