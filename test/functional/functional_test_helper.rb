require File.expand_path(File.dirname(__FILE__) + "/../test_helper.rb")

class Time
  class << self

    def now
      @time || original_new
    end

    alias_method :original_new, :new
    alias_method :new, :now

    def is(time = nil)
      raise "A block is required" unless block_given?
      begin
        previous, @time = @time, time || now
        yield
      ensure
        @time = previous
      end
    end
  end
end

module Test
  ExistingFileLocation = JUKEBOX_MUSIC_ROOT + "/Antony Raijekov/01 - When Waves Trying to Catch a Marvel.mp3"
  NonExistingFileLocation = JUKEBOX_MUSIC_ROOT + "/some artist that does not exist/some song.mp3"
  
  FirstTestTrack = JUKEBOX_MUSIC_ROOT + "/Antony Raijekov/01 - When Waves Trying to Catch a Marvel.mp3"
  SecondTestTrack = JUKEBOX_MUSIC_ROOT + "/Antony Raijekov/02 - Be Brave (feat. Norine Braun).mp3"
  ThirdTestTrack = JUKEBOX_MUSIC_ROOT + "/Antony Raijekov/03 - Lightin.mp3"
end