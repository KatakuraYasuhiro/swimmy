# coding: utf-8
#
# Yuuki Fujiwara / nomlab
# This is a part of https://github.com/nomlab/swimmy

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'json'
require 'uri'
require 'net/https'
require 'slack-ruby-bot'
require 'base'

BASE_URL_GEOCODE = "https://maps.google.com/maps/api/geocode/json"
BASE_URL_DIRECTIONS = "https://maps.googleapis.com/maps/api/directions/json"

module Swimmy
  module Command
    class Route_match < Swimmy::Command::Base
      match(/.*での.*から.*までの道/) do |client, data, match|
        json = {:user_name => data.user, :text => data.text}.to_json
        params = JSON.parse(json, symbolize_names: true)
        res = Route.new.distance_respond(params)
        text = JSON.parse(res)
        client.say(channel: data.channel, text: text["text"])
      end
    end

    class Route
      private
      def address_to_geocode(address)
        google_maps_api = ENV['GOOGLE_MAPS_API_KEY']
        address = URI.encode(address)
        hash = Hash.new

        reqUrl = "#{BASE_URL_GEOCODE}?address=#{address}&sensor=false&language=ja&key=" + google_maps_api

        response = Net::HTTP.get_response(URI.parse(reqUrl))

        case response
        when Net::HTTPSuccess then
          data = JSON.parse(response.body)
          if (data['results'] == [])
            return nil
          end

          hash['lat'] = data['results'][0]['geometry']['location']['lat']
          hash['lng'] = data['results'][0]['geometry']['location']['lng']
        else
          ponse.error!
        end

        return hash
      end

      def distribute_transport(params)
        transport = params[:text].match(/(.*)での.*から.*までの道/)
        if (transport[1] == "徒歩") then
          return "walking"
        elsif (transport[1] == "自動車") then
          return "driving"
        elsif (transport[1] == "電車")
          return "transit"
        else
          return "NotTransport"
        end
      end

      def get_route_info(params, options = {}, start, goal)
        google_maps_api = ENV['GOOGLE_MAPS_API_KEY']
        mode = distribute_transport(params)
        if (mode == nil)
          return nil
        end

        hash = Hash.new
        hash['distance'] = 0
        hash['duration'] = 0
        reqUrl = "#{BASE_URL_DIRECTIONS}?origin=#{start['lat']},#{start['lng']}&destination=#{goal['lat']},#{goal['lng']}&language=ja&mode=#{mode}&key=" + google_maps_api

        response = Net::HTTP.get_response(URI.parse(reqUrl))

        case response
        when Net::HTTPSuccess then
          data = JSON.parse(response.body)
          if (data['routes'] == []) then
            return nil
          end
          hash['distance'] = data['routes'][0]['legs'][0]['distance']['text']
          hash['duration'] = data['routes'][0]['legs'][0]['duration']['text']
        else
          hash['distance'] = 0
          hash['duration'] = 0
        end

        return hash
      end

      public
      def distance_respond(params, options = {})
        return nil if params[:user_name] == "slackbot" || params[:user_id] == "USLACKBOT"
        address = params[:text].match(/.*での(.*)から(.*)までの道/)
        p start = address_to_geocode(address[1])
        p goal  = address_to_geocode(address[2])
        if (start == nil || goal == nil)
          return {text: "測定できませんでした"}.merge(options).to_json
        end

        route_info = get_route_info(params, options, start, goal)
        if (route_info == "NotTransport") then
          return {text: "交通手段は徒歩か自動車か電車を選んでください"}.merge(options).to_json
        elsif (route_info == nil) then
          return {text: "測定できませんでした"}.merge(options).to_json
        end

        mode = distribute_transport(params)

        map = "https://www.google.co.jp/maps/dir/?api=1&origin=#{start['lat']},#{start['lng']}&destination=#{goal['lat']},#{goal['lng']}&travelmode=#{mode}"

        text = "距離は#{route_info['distance']}\nかかる時間は#{route_info['duration']}\n" + "詳しい道は<#{map}|こちら>"

        return {text: text}.merge(options).to_json
      end
    end
  end
end
