TARGETS_DRAFTS := draft-jimenez-mud-coap
TARGETS_TAGS := 
draft-jimenez-mud-coap-00.md: draft-jimenez-mud-coap.md
	sed -e 's/draft-jimenez-mud-coap-latest/draft-jimenez-mud-coap-00/g' $< >$@
