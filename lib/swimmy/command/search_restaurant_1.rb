# coding: euc-jp
=begin

require "net/http"
require "json"
require "rexml/document"

module Swimmy
  module Command
    class Search_restaurant < Swimmy::Command::Base

      command "search_restaurant" do |client,data,match|

        keyword = "������"

        # 1.url����Ϥ���
        encoded_URI = URI.encode "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=5a9f7a611fa1993e&keyword=#{keyword.encode("UTF-8")}"

        url = URI.parse(encoded_URI)
        # 2.http���̿������ꤹ��
        # �̿���Υۥ��Ȥ�ݡ��Ȥ�����
        https = Net::HTTP.new(url.host, url.port)
        # https���̿������硢use_ssl��true�ˤ���
        https.use_ssl = true
        # 3.�ꥯ�����Ȥ��������
        req = Net::HTTP::Get.new(url.path + "?" + url.query)
        # 4.�ꥯ�����Ȥ��ꤲ��/�쥹�ݥ󥹤�������
        res = https.request(req)
        # 5.�ǡ������Ѵ�����
        #binding.irb
        doc = REXML::Document.new(res.body)
        # ��̤����

        # 1~(SHOP�ξ�¿�)�δ֤�̵��٤˿�������
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
        desc "�᤯�ΰ���Ź�򸡺����ޤ�"
        long_desc "coming soon...!!!"
      end


    end #Class Search_restaurant
  end #module Command
end #module Swimmy
=end
