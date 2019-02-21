module Swimmy
  module Command
    dir = File.dirname(__FILE__) + "/command"
    
    require "#{dir}/issue_operation"
    require "#{dir}/lunch_time"
    require "#{dir}/rain_information"
    require "#{dir}/restaurant_information"
    require "#{dir}/route"
    require "#{dir}/poll"
    require "#{dir}/qiita_trend"
    require "#{dir}/photo_upload"
    require "#{dir}/lottery"
  end
end
