module Spree
  class CallbacksController < Spree::StoreController
    
    def checkout
       logger.debug "Parametros #{params}"
       @order = Order.find_by_number!(params[:noperacion])
       
       
       if(params[:resultado] == "APROBADA")
           self.update_order
       else
       
       end
       logger.debug 'processing checkout'
       render :text => 'ok'
    end
    
    def update_order
     if @order.update_attributes(object_params)
        fire_event('spree.checkout.update')

        if @order.next
          state_callback(:after)
        end
      end
    end
    
    def object_params
        payment_method_id = PaymentMethod::find_by_type(Spree::PaymentMethod::SpsPayment.name).id
       payment_source_attributes = {
         :cc_owner =>params[:titular],
         :installments => params[:cuotas],
         :cc_type => params[:tarjeta],
         :sps_response => params[:resultado],   
         :sps_tx_code => params[:codautorzacion],
         :sps_tx_date => params[:fechahora]    
       }
       {:payments_attributes => [{
       "payment_method_id"=>payment_method_id,
       "source_attributes"=>payment_source_attributes,
       "amount"=>@order.total
       }]}
       
      end
    
    def state_callback(before_or_after = :before)
        method_name = :"#{before_or_after}_#{@order.state}"
        send(method_name) if respond_to?(method_name, true)
     end
    
    ##
    ## Action used on test mode to fake the validation of the sps process first step
    ##
    def fake_validar
       sps = Spree::PaymentMethod::SpsPayment.new()
       if sps.prefers_test_mode?
          @order_total = params[:monto];
          @order_quota = params[:cuotas];
          @order_code  = params[:nrooperacion];
          @order_currency = '$';
         mediodepago = params[:mediodepago]
         case mediodepago 
          when "1" then
            render :partial => 'test/datostarjeta_visa'
          when "20" then
            render :partial => 'test/datostarjeta_mast'
          end
       else
         render :text => t('errors.validate_bad_request')
       end
    end
    
    ##
    ## Action used on test mode to fake the transaction confirmation from visa card of the sps process 
    ##
    def fake_confirmar_visa
       sps = Spree::PaymentMethod::SpsPayment.new()
       if sps.prefers_test_mode?
         @cc_owner           = params[:NOMBREENTARJETA];
         @cc_owner_mail      = params[:EMAILCLIENTE];
         @order_total        = params[:ORDER_TOTAL];
         @order_quota        = params[:ORDER_QUOTA];
         @order_currency     = params[:ORDER_CURRENCY];
         @order_code         = params[:ORDER_CODE];
         @date               = DateTime.now.to_s;
         
         data = {
           :Moneda=>@order_currency,
           :fechahora=>@date,
           :codautorzacion=>'999999',
           :cuotas=>@order_quota,
           :validafechanac=>'NO',
           :validanrodoc=>'NO',
           :titular=>@cc_owner,
           :monto =>@order_total,
           :tarjeta=>'Visa',
           :emailcomprador=>@cc_owner_mail,
           :validanropuerta=>'NO',
           :validatipodoc=>'SI',
           :noperacion=>@order_code,
           :resultado=>'APROBADA'
           }
         Thread.new do
         fake_response(data)  
         end
         order = Order.find_by_number!(@order_code)
         @orderhref = order_path(order)
         render :partial => 'test/operacionok_visa'
       else
         render :text => t('errors.validate_bad_request')
       end
    end
    
    ##
    ## Action used on test mode to fake the transaction confirmation from master card of the sps process 
    ##
    def fake_confirmar_master
       sps = Spree::PaymentMethod::SpsPayment.new()
       if sps.prefers_test_mode?
         @cc_owner           = params[:NOMBREENTARJETA];
         @cc_owner_mail      = params[:EMAILCLIENTE];
         @order_total        = params[:ORDER_TOTAL];
         @order_quota        = params[:ORDER_QUOTA];
         @order_currency     = params[:ORDER_CURRENCY];
         @order_code         = params[:ORDER_CODE];
         @date               = DateTime.now.to_s;
         Thread.new do
          fake_response({
             :Moneda=>@order_currency,
             :fechahora=>@date,
             :codautorzacion=>'999999',
             :cuotas=>@order_quota,
             :validafechanac=>'NO',
             :validanrodoc=>'NO',
             :titular=>@cc_owner,
             :monto =>@order_total,
             :tarjeta=>'Mastercard Pesos',
             :emailcomprador=>@cc_owner_mail,
             :validanropuerta=>'NO',
             :validatipodoc=>'SI',
             :noperacion=>@order_code,
             :resultado=>'APROBADA'
             }) 
           end
         @order = Order.find_by_number!(@order_code)
         order_url = order_path(@order)
         render :partial => 'test/operacionok_mast'
       else
         render :text => t('errors.validate_bad_request')
       end
    end

    ##
    ## Action used on test mode to fake the MASTERCARD transaction confirmation from master card of the sps process 
    ##
    def fake_validate_master
       sps = Spree::PaymentMethod::SpsPayment.new()
       if sps.prefers_test_mode?
         @cc_owner           = params[:NOMBREENTARJETA];
         @cc_owner_mail      = params[:EMAILCLIENTE];
         @cc_number          = params[:NROTARJETA];
         @cc_expire_date     = params[:VENCTARJETA];
         @cc_owner_doc_type  = params[:TIPODOC];
         @cc_owner_doc       = params[:NROTARJETA];
         @order_total        = params[:ORDER_TOTAL];
         @order_quota        = params[:ORDER_QUOTA];
         @order_currency     = params[:ORDER_CURRENCY];
         @order_code         = params[:ORDER_CODE];
         render :partial => 'test/confirmacion_mast'
       else
         render :text => t('errors.validate_bad_request')
       end
    end

    private 
    
    def fake_response(data)
      logger.debug "Data #{data}"
      require 'net/http'
      require "uri"
      x = Net::HTTP.post_form(URI.parse(url_for(:sps_checkout_callback)), data)
    end
  end
end
