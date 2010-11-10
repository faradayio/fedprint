class Contract < ActiveRecord::Base
  include Carbon
  emit_as :purchase do
    provide :industry
    provide :price, :as => :cost
  end
  
  def emission
    return footprint if footprint.present?
    update_attribute :footprint, emission_estimate.to_f
    footprint
  end
  
  class << self
    def create_from_feed(feed)
      feed.entries.map {|entry| create_from_entry entry}
    end
    
    def create_from_entry(entry)
      create_from_fpds_xml entry.content
    end
    
    def create_from_fpds_xml(fpds_xml)
      Rails.logger.info 'Creating contract from FPDS XML . . .'
      award = Nokogiri::XML(fpds_xml).at('.//ns1:award')
      piid = award.at('.//ns1:awardID/ns1:referencedIDVID/ns1:PIID').text
      Rails.logger.info " * #{piid}"
      if contract = find_by_piid(piid)
        return contract
      end
      agency = award.at('.//ns1:awardID/ns1:awardContractID/ns1:agencyID').attributes['name'].value
      Rails.logger.info " * #{agency}"
      vendor = award.at('.//ns1:vendor/ns1:vendorHeader/ns1:vendorName').text
      Rails.logger.info " * #{vendor}"
      industry = award.at('.//ns1:productOrServiceInformation/ns1:principalNAICSCode').text
      Rails.logger.info " * #{industry}"
      price = award.at('.//ns1:dollarValues/ns1:obligatedAmount').text
      Rails.logger.info " * #{price}"
      create :piid => piid, :agency => agency, :vendor => vendor, :industry => industry, :price => price
    rescue
      Rails.logger.info ' * (skipping bad award)'
      nil
    end
  end
end
