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
  
  def details
  end
  
  class << self
    def create_from_feed(feed)
      feed.entries.map {|entry| create_from_entry entry}.compact
    end
    
    def create_from_entry(entry)
      create_from_fpds_xml entry.content
    end
    
    def create_from_fpds_xml(fpds_xml)
      Rails.logger.info 'Creating contract from FPDS XML . . .'
      award = Nokogiri::XML(fpds_xml).at('.//ns1:award')
      contract = {}
      contract[:piid] = award.at('.//ns1:awardID/ns1:referencedIDVID/ns1:PIID').text
      Rails.logger.info " * #{contract[:piid]}"
      if existing_contract = find_by_piid(contract[:piid])
        Rails.logger.info ' * (skipping existing award)'
        return existing_contract
      end
      contract[:agency] = award.at('.//ns1:awardID/ns1:awardContractID/ns1:agencyID').attributes['name'].value
      Rails.logger.info " * #{contract[:agency]}"
      contract[:vendor] = award.at('.//ns1:vendor/ns1:vendorHeader/ns1:vendorName').text
      Rails.logger.info " * #{contract[:vendor]}"
      contract[:industry] = award.at('.//ns1:productOrServiceInformation/ns1:principalNAICSCode').text
      Rails.logger.info " * #{contract[:industry]}"
      contract[:price] = award.at('.//ns1:dollarValues/ns1:obligatedAmount').text
      Rails.logger.info " * #{contract[:price]}"
      if contracting_office = award.at('.//ns1:purchaserInformation/ns1:contractingOfficeAgencyID')
        contract[:contracting_office] = contracting_office.attributes['name'].value
      end
      if funding_office = award.at('.//ns1:purchaserInformation/ns1:fundingRequestingOfficeID')
        contract[:funding_office] = funding_office.attributes['name'].value
      end
      if product_or_service = award.at('.//ns1:productOrServiceInformation/ns1:productOrServiceCode')
        contract[:product_or_service] = product_or_service.attributes['description'].value
      end
      create contract
    rescue
      Rails.logger.info ' * (skipping bad award)'
      nil
    end
  end
end
