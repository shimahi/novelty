// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require nested_form_fields


//別送先を選択したとき、別送先のフォームを表示
jQuery(document).on('turbolinks:load', function() {
  if($('[id=order_another_shipping_false]').prop('checked')){
    $('.shipping-form-wrapper').hide();
  } else {
    $('.shipping-form-wrapper').show();
  }
  $('[name="order[another_shipping]"]:radio').change(function() {
    $('.shipping-form-wrapper').toggle();
  });
});

//配送先種別が個人のとき、部署/担当者のフォームを潰す
jQuery(document).on('turbolinks:load', function() {
  var selectedValue = $('.form-group.select.optional.order_shipping_is_company select');
  var target = $('.form-group.string.optional.order_shipping_division_name input, .form-group.string.optional.order_shipping_staff_name input');

  if (selectedValue.val() == "true") {
    target.prop('disabled', false);
  }
  selectedValue.change(function() {
    if(selectedValue.val() == "true") {
      target.prop('disabled', false);
    } else {
      target.prop('disabled', true);
    }
  });
});

//コースターを選択した場合、サイズのところをdisabledにし、その他でdisabledを解除
jQuery(document).on('turbolinks:load', function() {
  $("#new_order").on('change', '.item-data select', function(){
    var trigger = $(this);
    var target = trigger.parent().parent().next();
    if(trigger.val() == "coaster") {
      target.find("select").prop('disabled', true);
      target.find("select").val("")
    } else {
      target.find("select").prop('disabled', false);
      target.find("select").val("small")
      if(target.find("select option:first").val()== "") {
        target.find("select option:first").remove();
      }
    }
  });
});

// 郵便番号補完のち、番地にフォーカスさせる
jQuery(document).on('turbolinks:load', function() {
  AjaxZip3.onSuccess = function() {
    if ($("input[name='order[shipping_zip]']").is(':focus')) {
      $("input[name='order[shipping_addr4]']").focus();
    } else {
      $("input[name='order[customer_addr4]']").focus();
    }
  };
});