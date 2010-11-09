require 'open-uri'

class ContractsController < ApplicationController
  def index
    @contracts = Contract.create_from_feed(SimpleRSS.parse(open('https://www.fpds.gov/dbsight/FEEDS/ATOM?FEEDNAME=DETAIL&q=CONTRACT_TYPE:%22AWARD%22&sortBy=LAST_MOD_DATE&desc=Y')))
  end
end
