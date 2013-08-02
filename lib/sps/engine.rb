module Spree
module Sps 
class Engine < ::Rails::Engine
    isolate_namespace Spree
    engine_name 'Sps'
    
    def self.activate
       
    end
    
   initializer "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods += [ Spree::PaymentMethod::SpsPayment, Spree::PaymentMethod::Cash ]
    end
  end
end
end