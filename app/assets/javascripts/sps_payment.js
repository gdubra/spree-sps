$(document).ready(function() {
	
	$("#checkout_form_payment").submit(function() {
	   var radio_value = $("[name='order[payments_attributes][][payment_method_id]']:checked").val();
		if(radio_value == sps_payment_method_id){
		   $(this).attr('target',"sps_form");
		   $(this).attr('action',sps_action);
		   $("[data-hook='checkout_content']").append('<iframe id="sps_form" name="sps_form" style="border:none;width:100%;height:100%" >');
		   $("[name='sps_form']").load(function(){load_iframe(document.body.scrollHeight);});
		   $('input[name="_method"]').val('post');
    	}
    	return true; 
	});
});



function load_iframe(height){
	$('iframe[name="sps_form"]').show();
	$('[data-hook="checkout_form_wrapper"]').remove();
	$('iframe[name="sps_form"]').height(height);
}
