Gem::Specification.new do |s|
  s.name        = "weathermatic"
  s.version     = "0.0.11"
  s.summary     = "An API wrapper in Ruby for interfacing with the SmartLink Network site at my.smartlinknetwork.com"
  s.date        = "2014-10-28"
  s.description = "SmartLink provides a web portal which connects SmartLine controllers in the field to the cloud allowing basic operations like starting or stopping irrigation for a specific zone on a specified controller.  All controllers which belong to a customer account can be managed via the web portal, iOS and Android applications, or this API.  The current version is v2 of the API.  You must have a developer key in order to use this version."
  s.authors     = ["Tyler Merritt"]
  s.email       = ["tyler.merritt@weathermatic.com"]
  s.homepage    = "http://www.smartlinknetwork.com/"
  s.files       = ["lib/weathermatic.rb"]
  s.licenses		= "MIT"
end