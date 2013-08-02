Spree::Core::Engine.routes.draw do
   match '/sps/checkout' => 'callbacks#checkout', :as=> :sps_checkout_callback, :via => [:post]
   match '/sps/validar' => 'callbacks#fake_validar', :as=> :fake_sps_validar, :via => [:post]
   match '/sps/confirmar_visa' => 'callbacks#fake_confirmar_visa', :as=> :fake_sps_confirmar_visa, :via => [:post]
   match '/sps/confirmar_master' => 'callbacks#fake_confirmar_master', :as=> :fake_sps_confirmar_master, :via => [:post]
   match '/sps/validar_master' => 'callbacks#fake_validate_master', :as=> :fake_sps_validate_master, :via => [:post]
end
