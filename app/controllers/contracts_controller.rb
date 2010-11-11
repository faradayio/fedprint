class ContractsController < ApplicationController
  def index
    @contracts = Contract.order('updated_at DESC').limit(10)
    @last_updated = @contracts.first.updated_at
  end
end
