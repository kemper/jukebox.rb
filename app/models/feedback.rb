class Feedback < ActiveRecord::Base
  set_table_name "feedback"
  Like = "Like"
  Dislike = "Dislike"
  Hate = "Hate"
end