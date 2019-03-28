###*
 * Element matches
###
unless Element::matches
	Element::matches = 
		Element::matchesSelector || 
		Element::mozMatchesSelector ||
		Element::msMatchesSelector || 
		Element::oMatchesSelector || 
		Element::webkitMatchesSelector