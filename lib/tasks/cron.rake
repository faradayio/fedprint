require 'open-uri'

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Contract.create_from_feed(SimpleRSS.parse(open('https://www.fpds.gov/dbsight/FEEDS/ATOM?FEEDNAME=DETAIL&q=CONTRACT_TYPE:%22AWARD%22&sortBy=LAST_MOD_DATE&desc=Y').read))
end
