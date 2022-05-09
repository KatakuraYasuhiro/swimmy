# coding: euc-jp
=begin

require "net/http"
require "json"
require "rexml/document"

module Swimmy
  module Command
    class Search_restaurant < Swimmy::Command::Base

      command "search_restaurant" do |client,data,match|

        keyword = "岡山駅"

        # 1.urlを解析する
        encoded_URI = URI.encode "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=5a9f7a611fa1993e&keyword=#{keyword.encode("UTF-8")}"

        url = URI.parse(encoded_URI)
        # 2.httpの通信を設定する
        # 通信先のホストやポートを設定
        https = Net::HTTP.new(url.host, url.port)
        # httpsで通信する場合、use_sslをtrueにする
        https.use_ssl = true
        # 3.リクエストを作成する
        req = Net::HTTP::Get.new(url.path + "?" + url.query)
        # 4.リクエストを投げる/レスポンスを受け取る
        res = https.request(req)
        # 5.データを変換する
        #binding.irb
        doc = REXML::Document.new(res.body)
        # 結果を出力

        # 1~(SHOPの上限数)の間で無作為に数を選ぶ
        upper_limit = doc.get_elements("//results/shop").size
        random_num = rand(1..upper_limit)


text = <<-"EOS"
#{doc.elements["results/shop[#{random_num}]/name"].text}
#{doc.elements["results/shop[#{random_num}]/address"].text}
#{doc.elements["results/shop[#{random_num}]/open"].text}
#{doc.elements["results/shop[#{random_num}]/urls/pc"].text}
EOS
      
        client.say(channel: data.channel,text: text )

      end

      help do
        title "search_restaurant"
        desc "近くの飲食店を検索します"
        long_desc "coming soon...!!!"
      end


    end #Class Search_restaurant
  end #module Command
end #module Swimmy
=end
