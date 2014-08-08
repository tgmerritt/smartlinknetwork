SmartLink Network v2 API
================

A Ruby Gem for integrating with Weathermatic's SmartLink Network via API

Documentation for the entire API is hosted at Apiary: http://docs.smartlinknetworkv2.apiary.io/

The gem is available via RubyGems.  

In your Gemfile:

gem 'weathermatic'

Then run `bundle install` to include the gem in your application.  The gem assumes that you use environment variables to store sensitive credentials.  You will need to register with Weathermatic as a developer, and upon registration you will receive your API token and secret token.  These are the credentials which should be set as environment variables SLN_API_KEY and SLN_API_SECRET_KEY.  Examples are included in the source code of the gem.
