class ContractsController < ApplicationController
  def index
    @contracts = Contract.order('updated_at DESC').limit(10)
  end
end
