//= require active_admin/base
//= require turbolinks
//= require nested_form_fields

/* activeadminページ内の要素のみをセレクタとして扱うこと！*/


//[発注]先種別が個人のとき、部署/担当者のフォームを潰す
jQuery(document).on('turbolinks:load', function() {
  var customerTrigger = $('#active_admin_content #order_customer_is_company');
  var target = $('#order_customer_division_name, #order_customer_staff_name');
  if (customerTrigger.val() == "false") {
    target.prop('disabled', true);
    target.parent().hide();
  }
  customerTrigger.change(function() {
    if(customerTrigger.val() == "true") {
      target.prop('disabled', false);
      target.parent().show();
    } else {
      target.prop('disabled', true);
      target.parent().hide();
    }
  });
});
//[配送]先種別が個人のとき、部署/担当者のフォームを潰す
jQuery(document).on('turbolinks:load', function() {
  var trigger = $('#active_admin_content #order_shipping_is_company');
  var target = $('#active_admin_content #order_shipping_division_name, #order_shipping_staff_name');
  if (trigger.val() == "false") {
    target.prop('disabled', true);
    target.parent().hide();
  }
  trigger.change(function() {
    if(trigger.val() == "true") {
      target.prop('disabled', false);
      target.parent().show();
    } else {
      target.prop('disabled', true);
      target.parent().hide();
    }
  });
});

//別送先にチェックを入れたとき、別送先のフォームを表示
$(document).on('turbolinks:load', function() {
  var shipping_forms = $('.admin-shipping-form-wrapper');

  if(!$("#order_another_shipping").prop('checked')) {
    shipping_forms.hide();
  }
  $("#order_another_shipping").change(function() {
      shipping_forms.toggle();
  });
});



