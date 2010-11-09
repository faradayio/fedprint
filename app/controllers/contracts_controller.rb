require 'open-uri'

class ContractsController < ApplicationController
  def index
    @contracts = Contract.create_from_feed(fpds_feed)
  end
  
  private
  
  def fpds_feed
    cache_key = "#{__FILE__}/fpds_feed"
    if Rails.cache.exist? cache_key
      cache_data = Rails.cache.read cache_key
    else
      cache_data = open('https://www.fpds.gov/dbsight/FEEDS/ATOM?FEEDNAME=DETAIL&q=CONTRACT_TYPE:%22AWARD%22&sortBy=LAST_MOD_DATE&desc=Y').read
      Rails.cache.write cache_key, cache_data, :expires_in => 1.hour
    end
    SimpleRSS.parse cache_data
  end
end
