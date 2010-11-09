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
      award = Nokogiri::XML(fpds_xml).at('.//ns1:award')
      piid = award.at('.//ns1:awardID/ns1:referencedIDVID/ns1:PIID').text
      if contract = find_by_piid(piid)
        return contract
      end
      agency = award.at('.//ns1:awardID/ns1:awardContractID/ns1:agencyID').attributes['name'].value
      vendor = award.at('.//ns1:vendor/ns1:vendorHeader/ns1:vendorName').text
      industry = award.at('.//ns1:productOrServiceInformation/ns1:principalNAICSCode').text
      price = award.at('.//ns1:dollarValues/ns1:obligatedAmount').text
      create :piid => piid, :agency => agency, :vendor => vendor, :industry => industry, :price => price
    end
  end
end
