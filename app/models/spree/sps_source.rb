module Spree
  class SpsSource < ActiveRecord::Base
    attr_accessible :cc_owner, :cc_type, :installments, :sps_response, :sps_tx_code, :sps_tx_date
    
    def actions
      %w{capture refund}
    end
    
    def can_capture?(payment)
      (payment.state == 'pending' || payment.state == 'checkout') && self.success?
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state == 'completed' && self.success?
    end
    
    def can_refund?(payment)
      payment.state == 'completed' && self.success?
    end
    
    def success?
      sps_response == "APROBADA"
    end
  end
end
