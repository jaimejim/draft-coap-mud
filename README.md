# Using MUD in CoAP

This is the working area for the Individual internet-draft, "Using MUD in CoAP".

* [Editor's copy](https://jaime.win/draft-coap-mud/draft-jimenez-mud-coap.html)  [![Build Status](https://travis-ci.org/jaimejim/draft-coap-mud.svg?branch=master)](https://travis-ci.org/jaimejim/draft-coap-mud)

## Building the Draft

Formatted TXT, XML and HTML versions of the draft can be built using `make`.

```sh
$ make
cat draft-jimenez-mud-coap.md   | kramdown-rfc2629 | lib/add-note.py > draft-jimenez-mud-coap.xml
xml2rfc -q  draft-jimenez-mud-coap.xml -o draft-jimenez-mud-coap.txt --text
xml2rfc -q  draft-jimenez-mud-coap.xml -o draft-jimenez-mud-coap.htmltmp --html
(cat draft-jimenez-mud-coap.htmltmp;echo) | sed -f lib/addstyle.sed > draft-jimenez-mud-coap.html
rm draft-jimenez-mud-coap.htmltmp draft-jimenez-mud-coap.xml
```

This requires that you have the necessary software installed.  See [the
instructions](https://github.com/martinthomson/i-d-template/blob/master/doc/SETUP.md).

## Contributing

See the [guidelines for contributions](https://github.com/jaimejim/draft-coap-mud/blob/master/CONTRIBUTING.md).
