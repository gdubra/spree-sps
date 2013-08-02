
  class Spree::PaymentMethod::SpsPayment < Spree::PaymentMethod
    preference :client_id, :string
    preference :test_mode, :boolean, :default => true
    preference :pre_authorize_transactions, :boolean, :default => false
    preference :username, :string
    preference :password, :string
    attr_accessible :preferred_client_id, :preferred_test_mode, :preferred_pre_authorize_transactions, :preferred_username, :preferred_password
    
    def payment_source_class
      SpsRequest
    end
    
    #if pre_authorize_transactions is true then on checkout processing! authorize will be executed
    def authorize(money, source, options = {})
      logger.debug 'SPS ACTION: authorize'
      return ActiveMerchant::Billing::Response.new(source.success?, "Authorize Error", {:message => ""}, {})
    end
    
    #if pre_authorize_transactions is false then on checkout processing purchase will be executed
    def purchase(money, source, options = {})
      logger.debug 'SPS ACTION: purchase'
      return ActiveMerchant::Billing::Response.new(source.success?, "Authorize Error", {:message => ""}, {})
    end

    def capture(money, source, options = {})
      logger.debug 'SPS ACTION: capture'
      if :preferred_test_mode
        return ActiveMerchant::Billing::Response.new(true, "", {}, {})
      end
    end

    def void(response_code, options = {})
      #if we are on test mode we don't do anything jut emulate it was voided
      return ActiveMerchant::Billing::Response.new(true, "", {}, {}) if self.preferred_test_mode
      order_payment_number = options[:order_id].split('-')
      payment_identifier = order_payment_number[1]
      payment = Spree::Payment.find_by_identifier!(payment_identifier)
      source = payment.source
      require 'xmlrpc/client'
      server = XMLRPC::Client.new2("https://sps.decidir.com/sps-ar/SacXmlRpcServer")
      server.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
      result = server.call("anularTransaccion",self.preferred_username,self.preferred_password,self.preferred_client_id,source.sps_tx_code)
      logger.debug "XLRPC RESPONSE  #{result.to_yaml}"
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end
    
    def refund(response_code, options = {})
      #if we are on test mode we don't do anything jut emulate it was voided
      return ActiveMerchant::Billing::Response.new(true, "", {}, {}) if self.preferred_test_mode
     
      order_payment_number = options[:order_id].split('-')
      payment_identifier = order_payment_number[1]
      payment = Spree::Payment.find_by_identifier!(payment_identifier)
      source = payment.source
      require 'xmlrpc/client'
      server = XMLRPC::Client.new2("https://sps.decidir.com/sps-ar/SacXmlRpcServer")
      server.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
      result = server.call("devolverTransaccion",self.preferred_username,self.preferred_password,self.preferred_client_id,source.sps_tx_code)
      logger.debug "XLRPC RESPONSE  #{result.to_yaml}"
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def source_required?
      true
    end
    
    def payment_source_class
      Spree::SpsSource
    end
    
    def payment_profiles_supported?
      false
    end
    
    def auto_capture?
      return !self.preferred_pre_authorize_transactions
    end
    
  end
