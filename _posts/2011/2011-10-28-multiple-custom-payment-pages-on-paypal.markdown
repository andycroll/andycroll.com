---
title: Multiple Custom Payment Pages on Paypal
layout: post
category: development
redirect_from:
  - /2011/10/28/multiple-custom-payment-pages-on-paypal/
  - /ruby/multiple-custom-payment-pages-on-paypal/
image: '2011/multiple-custom-payment-pages-on-paypal'
imagealt: 'Paypal'
---

Paypal allows merchants to customize it's payment pages by adding logos and changing colors. We use this at ImpulseFlyer for our partnership with WSJ Asia.

To do this you pass a "page_style" variable with a value matching the name of your custom style in the standard Website Payments Standard form/button. It says so in [the documentation](https://www.paypal.com/cgi-bin/webscr?cmd=p/mer/cowp_summary-outside).

However it took a lot of digging and guesswork to finally make it work. Initially I set up our custom ImpulseFlyer style and made it 'Primary' as suggested, then when I tried to pass a different 'WSJ' style I still got our primary page style.

The fix is simple, leave the non-deletable 'PayPal' style as the 'Primary' and **always** set a page_style in your form code. *Job done*.
