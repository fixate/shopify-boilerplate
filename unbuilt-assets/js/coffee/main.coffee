'use strict'





do () ->
  window.$document = $(document)
  window.$window = $(window)





#--------------------------------------------------#
# AJAX CART
#--------------------------------------------------#
do () ->
  if window.shopifyData.enableAjax
    jQuery ($) ->
      ajaxCart.init
        formSelector: '#AddToCartForm'
        cartContainer: '#CartContainer'
        addToCartSelector: '#AddToCart'
        cartCountSelector: '#CartCount'
        cartCostSelector: '#CartCost'
        moneyFormat: window.shopifyData.moneyFormat
      return

    jQuery('body').on 'ajaxCart.afterCartLoad', (evt, cart) ->
      timber.RightDrawer.open()
      return






#--------------------------------------------------#
# PRODUCTS
#--------------------------------------------------#
do () ->
  if window.shopifyData.template == 'product'
    product = window.productData.product

    window.selectCallback = (variant, selector) ->
      timber.productPage
        money_format: window.productData.moneyFormat
        variant: variant
        selector: selector
      return

    jQuery ($) ->
      new (Shopify.OptionSelectors)('productSelect',
        product: product
        onVariantSelected: selectCallback
        enableHistoryState: true)

      if product.options.length == 1 && product.options[0] != 'Title'
        $('.selector-wrapper:eq(0)').prepend "<label for='productSelect-option-0'>#{product.options[0]}</label>"

      if product.variants.length == 1 && product.variants[0] != 'Default'
        $('.selector-wrapper').hide()
      return





#--------------------------------------------------#
# JANK-FREE SCROLL - http://www.thecssninja.com/javascript/pointer-events-60fps
#--------------------------------------------------#
do () ->
  body = document.body
  timer = undefined
  if typeof body.classList != 'undefined'
    $window.on 'scroll', () ->
      clearTimeout timer
      body.classList.add "disable-hover"  unless body.classList.contains("disable-hover")
      timer = setTimeout(->
        body.classList.remove "disable-hover"
        return
      , 50)
      return

  $('html').removeClass('no-js')
