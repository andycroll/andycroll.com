---
title: "Textile Formatting for the hCard Microformat"
layout: post
category: development
redirect_from:
  - /2009/10/29/textile-formatting-for-the-hcard-microformat
---

Wouldn't it be nice if you could publish it in an [hCard](http://microformats.org/wiki/hcard) compatible format... and look, you can!

```textile
notextile. <div class="vcard">
p(tel). %(value)020% %(value)8642% %(value)7634%
p. "(email)mail@company.com":mailto:mail@company.com
p(adr). "(fn org url)Company Name":http://companyurl.com
%(street-address)Street Address%
%(locality)Locality%
%(region)Region%
%(postal-code)POST CODE%
%(country-name)Country Name%
notextile. </div>
```

Enjoy.
