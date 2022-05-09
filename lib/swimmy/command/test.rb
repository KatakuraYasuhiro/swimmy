# coding: euc-jp
require "net/http"
require "json"
require "rexml/document"


keyword = "������"
#binding.irb

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

#binding.irb
#������̤�ɽ������
puts doc.elements["results/shop[#{random_num}]/name"].text
puts doc.elements["results/shop[#{random_num}]/address"].text
puts doc.elements["results/shop[#{random_num}]/open"].text
puts doc.elements["results/shop[#{random_num}]/urls/pc"].text
