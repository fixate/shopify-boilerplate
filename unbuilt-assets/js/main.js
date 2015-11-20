'use strict';
(function() {
  window.$document = $(document);
  return window.$window = $(window);
})();

(function() {
  if (window.shopifyData.enableAjax) {
    jQuery(function($) {
      ajaxCart.init({
        formSelector: '#AddToCartForm',
        cartContainer: '#CartContainer',
        addToCartSelector: '#AddToCart',
        cartCountSelector: '#CartCount',
        cartCostSelector: '#CartCost',
        moneyFormat: window.shopifyData.moneyFormat
      });
    });
    return jQuery('body').on('ajaxCart.afterCartLoad', function(evt, cart) {
      timber.RightDrawer.open();
    });
  }
})();

(function() {
  var product;
  if (window.shopifyData.template === 'product') {
    product = window.productData.product;
    window.selectCallback = function(variant, selector) {
      timber.productPage({
        money_format: window.productData.moneyFormat,
        variant: variant,
        selector: selector
      });
    };
    return jQuery(function($) {
      new Shopify.OptionSelectors('productSelect', {
        product: product,
        onVariantSelected: selectCallback,
        enableHistoryState: true
      });
      if (product.options.length === 1 && product.options[0] !== 'Title') {
        $('.selector-wrapper:eq(0)').prepend("<label for='productSelect-option-0'>" + product.options[0] + "</label>");
      }
      if (product.variants.length === 1 && product.variants[0] !== 'Default') {
        $('.selector-wrapper').hide();
      }
    });
  }
})();

(function() {
  var body, timer;
  body = document.body;
  timer = void 0;
  if (typeof body.classList !== 'undefined') {
    $window.on('scroll', function() {
      clearTimeout(timer);
      if (!body.classList.contains("disable-hover")) {
        body.classList.add("disable-hover");
      }
      timer = setTimeout(function() {
        body.classList.remove("disable-hover");
      }, 50);
    });
  }
  return $('html').removeClass('no-js');
})();
