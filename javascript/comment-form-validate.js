/*--------------------------------------------------
		 CONTACT FORM CODE
---------------------------------------------------*/
jQuery(document).ready(function($){
	$('form#comment-form').submit(function() {
		$('form#comment-form .contact-error').remove();
		var hasError = false;
		$('form#comment-form .requiredField').each(function() {
			if(jQuery.trim($(this).val()) == '') {
            	var labelText = $(this).prev('label').text();
            	$(this).parent().append('<span class="contact-error">Required</span>');
            	$(this).addClass('inputError');
            	hasError = true;
            } else if($(this).hasClass('email')) {
            	var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
            	if(!emailReg.test(jQuery.trim($(this).val()))) {
            		var labelText = $(this).prev('label').text();
            		$(this).parent().append('<span class="contact-error">Invalid</span>');
            		$(this).addClass('inputError');
            		hasError = true;
            	}
            }
		});
		if(!hasError) {
			var formInput = $(this).serialize();
			$.post($(this).attr('action'),formInput, function(data){
				$("form#comment-form").before('<div class="contact-success"><strong>THANK YOU!</strong><p>Your email was successfully sent. We will contact you as soon as possible.</p></div>');
			});
		}


		return false;

	});
});
       