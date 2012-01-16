---
title: "Textile Formatting for the hCard Microformat"
layout: post
---

Just a quick one. I'm an avid Textpattern user and sometimes I want to put addresses in an article body. Wouldn't it be nice if you could publish it in an [hCard](http://microformats.org/wiki/hcard) compatible format... and look, you can!

    notextile. <div class="vcard">
    h3. Telephone
    p(tel). %(value)020% %(value)8642% %(value)7634%
    h3. Email
    p. "(email)mail@company.com":mailto:mail@company.com
    h3. Address
    p(adr). "(fn org url)Company Name":http://companyurl.com
    %(street-address)Street Address%
    %(locality)Locality%
    %(region)Region%
    %(postal-code)POST CODE%
    %(country-name)Country Name%
    notextile. </div>

Enjoy.