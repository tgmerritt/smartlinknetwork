class WeatherMatic
  attr_reader :username, :password
  require 'net/http'
  require 'uri'
  require 'openssl'
  require 'json'
  require 'base64'

  # Usage: wm = WeatherMatic.new(:username => 'YOUR USERNAME', :password => 'YOUR PASSWORD')
  # Automatically sets the base_uri to staging or production so that we don't have to change it by hand - should only be production for public release.

  def initialize(args)
    @username = args[:username]
    @password = args[:password]
    @base_uri = "https://my.smartlinknetwork.com"
    # @base_uri = 'http://localhost:3000'
  end

  # All requests are essentially the same - the purpose of this note is really just to show the basic authorization header for reference
  # Example Request:
  # {
  #   "accept-encoding"=>["gzip;q=1.0,deflate;q=0.6,identity;q=0.3"], 
  #   "accept"=>["application/json"], 
  #   "user-agent"=>["Ruby"], 
  #   "content-type"=>["application/json"], 
  #   "authorization"=>["Basic thisisnotarealbasicauthorizationstringbuthackitifyoumust=="]
  # }

  # Usage: wm.sites_list
  
  # Returns a list of all sites that you have permission to administer.  Permissions are set within the SmartLink UI
  # 
  # Example Response:
  #  {  
  #    "meta":{  
  #       "access":true,
  #       "hmac":true,
  #       "success":true,
  #       "request":{  
  #          "timestamp":"1407355110",
  #          "action":"index",
  #          "controller":"api/v2/sites",
  #          "site":{  

  #          },
  #          "filters":{  

  #          }
  #       },
  #       "message":null
  #    },
  #    "total":1,
  #    "total_pages":1,
  #    "page_num":1,
  #    "per_page":50,
  #    "result":{  
  #       "sites":[  
  #          {  
  #             "address1":"3425 Black Canyon",
  #             "address2":"",
  #             "city":"Plano",
  #             "state":"TX",
  #             "contact":"",
  #             "name":"Test Site",
  #             "latitude":"33.084593",
  #             "longitude":"-96.759224",
  #             "id":223,
  #             "site_href":"/sites/223",
  #             "reports_href":"/sites/223/report",
  #             "create_controller_href":"/sites/223/new_controller",
  #             "can_edit":true,
  #             "can_read":true,
  #             "controllers":[  
  #                {  
  #                   "name":"NS Test 1",
  #                   "run_status":0,
  #                   "id":754,
  #                   "location":"Plano, TX",
  #                   "activation_status":1,
  #                   "controller_href":"/controls/754",
  #                   "faults":[  
  #                      {  
  #                         "description":"Aircard Communications Error",
  #                         "date":"2014-01-16T09:09:50Z",
  #                         "id":6746
  #                      }
  #                   ],
  #                   "alerts":[  

  #                   ]
  #                }
  #             ]
  #          }
  #       ]
  #    }
  # }

  def sites_list
    uri = parse_uri(@base_uri+"/api/v2/sites?"+add_timestamp)
    puts uri
    @request = make_get(uri)
    make_request(uri,@request)
  end

  # This turns controllers 684 and 750 'on' - you can get the controller ID out of the list_sites reply.  You will only be able to run this command against controllers you own.
  # Possible commands: remote_on, remote_off, rain_delay (requires :rain_delay => INTEGER param), clear_all_faults, stop_all
  #
  # Usage: wm.global_batch_command(:instruction_type => "2", :payload => {"action"=>"remote_on"}, :controllers => ["684","750"]) 
  #
  # Example Response
  #   {  
  #    "meta":{  
  #       "access":true,
  #       "hmac":true,
  #       "success":true,
  #       "message":null,
  #       "request":{  
  #          "instruction_type":"2",
  #          "payload":{  
  #             "action":"remote_on"
  #          },
  #          "controllers":[  
  #             "699",
  #             "700"
  #          ],
  #          "timestamp":"1407510064",
  #          "action":"create",
  #          "controller":"api/v2/batches",
  #          "batch":{  
  #             "instruction_type":"2",
  #             "payload":{  
  #                "action":"remote_on"
  #             },
  #             "controllers":[  
  #                "699",
  #                "700"
  #             ],
  #             "timestamp":"1407510064"
  #          }
  #       }
  #    },
  #    "result":{  
  #       "user":{  
  #          "id":205,
  #          "name":"Tyler Merritt",
  #          "email":"tyler.merritt@weathermatic.com"
  #       },
  #       "affected":[  
  #          {  
  #             "global_batch_id":47,
  #             "controller_id":699,
  #             "instruction_id":109,
  #             "action":null,
  #             "description":null
  #          },
  #          {  
  #             "global_batch_id":47,
  #             "controller_id":700,
  #             "instruction_id":110,
  #             "action":null,
  #             "description":null
  #          }
  #       ],
  #       "instructions":[  
  #          {  
  #             "id":109,
  #             "type_common_name":"Command",
  #             "exception":null,
  #             "is_overnight":false,
  #             "status_id":1,
  #             "action":"Remote On",
  #             "user":"Tyler Merritt",
  #             "status":"Queued",
  #             "started_at":null,
  #             "ended_at":null,
  #             "delay_run_time":null,
  #             "controller":{  
  #                "modem_version":"0.18",
  #                "created_at":"2013-02-15T18:08:29Z",
  #                "id":699,
  #                "name":"Super Roamer",
  #                "controller_href":"/controls/699"
  #             }
  #          },
  #          {  
  #             "id":110,
  #             "type_common_name":"Command",
  #             "exception":null,
  #             "is_overnight":false,
  #             "status_id":1,
  #             "action":"Remote On",
  #             "user":"Tyler Merritt",
  #             "status":"Queued",
  #             "started_at":null,
  #             "ended_at":null,
  #             "delay_run_time":null,
  #             "controller":{  
  #                "modem_version":"0.18",
  #                "created_at":"2013-02-15T22:19:19Z",
  #                "id":700,
  #                "name":"TMOB",
  #                "controller_href":"/controls/700"
  #             }
  #          }
  #       ]
  #    }
  # }

  def global_batch_command(params)
    uri = parse_uri(@base_uri+"/api/v2/batches")
    @request = make_post(uri)
    if params[:payload]['action'] == "rain_delay"
      params_hash = ({"instruction_type" => params[:instruction_type], "payload" => params[:payload], "controllers" => params[:controllers], "rain_delay" => params[:rain_delay], "timestamp" => Time.now.to_i.to_s}).to_json
    else
      params_hash = ({"instruction_type" => params[:instruction_type], "payload" => params[:payload], "controllers" => params[:controllers], "timestamp" => Time.now.to_i.to_s}).to_json
    end
    @request.body = params_hash
    make_request(uri,@request)
  end

  # Gathers zone information about a single controller.  Params are ":id => 'value'" where $value is a string

  # Usage : wm.controller_zones(:id => '684')

  # Example response:
  #   {  
  #    "meta":{  
  #       "access":true,
  #       "success":true,
  #       "hmac": "pass",
  #       "request":{  
  #          "timestamp":"1407357310",
  #          "format":"json",
  #          "action":"index",
  #          "controller":"api/v2/zones",
  #          "id":"699",
  #          "zone":{  

  #          }
  #       },
  #       "message":null
  #    },
  #    "result":{  
  #       "zone":[  
  #          {  
  #             "id":38265,
  #             "number":1,
  #             "description":null,
  #             "sprinkler_type":2,
  #             "plant_type":3,
  #             "soil_type":1,
  #             "soil_slope":0,
  #             "adjustment":0,
  #             "created_at":"2012-01-03T22:18:28Z",
  #             "updated_at":"2012-01-05T21:51:09Z",
  #             "controller_id":699,
  #             "plant_type_definition_type":null,
  #             "sprinkler_type_definition_type":"index",
  #             "ignore_rain":false,
  #             "ignore_freeze":false,
  #             "ignore_sensor":false,
  #             "gpm":null,
  #             "valve_size":"0.0",
  #             "mv_enabled":null,
  #             "realtime_flow_enabled":false,
  #             "high_flow_limit":65535,
  #             "low_flow_limit":0,
  #             "current_seconds_ran":0,
  #             "running_average_reset_date":null,
  #             "current_average_flow":0,
  #             "ppg":null
  #          },
  #          {  
  #             "id":38266,
  #             "number":2,
  #             "description":null,
  #             "sprinkler_type":2,
  #             "plant_type":3,
  #             "soil_type":1,
  #             "soil_slope":0,
  #             "adjustment":10,
  #             "created_at":"2012-01-03T22:18:28Z",
  #             "updated_at":"2012-01-05T21:51:09Z",
  #             "controller_id":699,
  #             "plant_type_definition_type":null,
  #             "sprinkler_type_definition_type":"index",
  #             "ignore_rain":false,
  #             "ignore_freeze":false,
  #             "ignore_sensor":false,
  #             "gpm":null,
  #             "valve_size":"0.0",
  #             "mv_enabled":null,
  #             "realtime_flow_enabled":false,
  #             "high_flow_limit":65535,
  #             "low_flow_limit":0,
  #             "current_seconds_ran":0,
  #             "running_average_reset_date":null,
  #             "current_average_flow":0,
  #             "ppg":null
  #          }
  #       ]
  #    }
  # }

  def controller_zones(params)
    uri = parse_uri(@base_uri+"/api/v2/controllers/"+params[:id].to_s+"/zones?"+add_timestamp)
    @request = make_get(uri)
    make_request(uri,@request)
  end

  # Example - 
  # params[:id] = The ID of the controller you want to manually run as a STRING
  # params[:run_action] = "start" <-- must be explicitly passed
  # params[:program] = INTEGER.  Valid options are 1, 2, 3, or 4 corresponding to the programs on the controller
  # params[:zone] = INTEGER.  1-64.  If you send a zone that does not exist, you will get an error
  # params[:run_time] = INTEGER in minutes.  0-60 will run zones for $this number of minutes.  61+ will run in 5 minute increments.  Example - passing 62 will run for 70 minutes (60 minutes in single-minute intervals, 2 in two 5-minute increments or 10.  60 + 10 = 70)
  # params[:valve_zone] = INTEGER.  1-64.  If you send a valve zone that does not exist, you will get an error

  # Usage: wm.controller_manual_run(:run_action => "start", :zone => 1, :id => "699")

  # Example Response:
  #   {  
  #    "meta":{  
  #       "access":true,
  #       "hmac":{  
  #          "pass":true
  #       },
  #       "success":true,
  #       "request":{  
  #          "run_action":"start",
  #          "program":null,
  #          "zone":1,
  #          "run_time":null,
  #          "valve_zone":null,
  #          "timestamp":"1407353317",
  #          "format":"json",
  #          "action":"manual_run",
  #          "controller":{  

  #          },
  #          "id":"700"
  #       },
  #       "message":null
  #    },
  #    "result":{  
  #       "instruction":{  
  #          "id":16,
  #          "type_common_name":"Command",
  #          "exception":null,
  #          "is_overnight":false,
  #          "status_id":1,
  #          "action":"Manual Run ( minutes)",
  #          "user":"Tyler Merritt",
  #          "status":"Queued",
  #          "started_at":null,
  #          "ended_at":null,
  #          "delay_run_time":null,
  #          "controller":{  
  #             "modem_version":"0.18",
  #             "created_at":"2013-02-15T22:19:19Z",
  #             "id":700,
  #             "name":"TMOB",
  #             "controller_href":"/controls/700"
  #          }
  #       }
  #    }
  # }

  def controller_manual_run(params)
    uri = parse_uri(@base_uri+"/api/v2/controllers/"+params[:id].to_s+"/manual_run.json")
    @request = make_post(uri)
    @request.body = ({
                      "run_action" => params[:run_action], 
                      "program" => params[:program], 
                      "zone" => params[:zone],
                      "run_time" => params[:run_time],
                      "valve_zone" => params[:valve_zone],
                      "timestamp" => Time.now.to_i.to_s
                    }).to_json
    make_request(uri,@request)
  end

  # Returns information about your user account

  # Usage: wm.me

  # Example Response:
  #   {
  #    "meta":{
  #       "access":true,
  #       "hmac":true,
  #       "success":true,
  #       "request":{
  #          "timestamp":"1407352539",
  #          "action":"me",
  #          "controller":"api/v2/users",
  #          "user":{

  #          }
  #       },
  #       "message":null
  #    },
  #    "result":{
  #       "user":{
  #          "id":205,
  #          "email":"tyler.merritt@weathermatic.com",
  #          "first_name":"Tyler",
  #          "last_name":"Merritt",
  #          "address_1":"3301 W Kingsley Rd.",
  #          "address_2":"",
  #          "city":"Garland",
  #          "company":"",
  #          "phone_1":null,
  #          "phone_2":null,
  #          "phone_3":null,
  #          "postal":"75041",
  #          "province":"Texas",
  #          "temp_units":"f"
  #       }
  #    }
  # }

  def me
    uri = parse_uri(@base_uri+"/api/v2/users/me?"+add_timestamp)
    @request = make_get(uri)
    make_request(uri,@request)
  end

  # Example 
  # params[:range_start] should be passed as 'YYYY-MM-DD' as the start date (on and after) you would like a usage report from
  # params[:range_end] should be passed as 'YYYY-MM-DD' as the end date (on and before) you would like the usage report from
  # params[:interval] *optional* w = Weekly Intervals, m = Monthly Intervals, y = Yearly Intervals.  SUM of the usage by Interval passed
  # params[:controller_id] *optional* pass a specific controller ID or an array of controller IDs with the request to get controller usage instead of entire SITE usage
  # params[:zone_number] *optional* pass a specific zone number with the request to get zone usage instead of entire SITE usage (DEPENDS ON A SINGLE CONTROLLER ALSO BEING PASSED)
  
  # Usage: wm.site_usage(:site_id => 157, :controller_id => [794,750], :range_start => "2014-06-01", :range_end => "2014-07-25", :interval => 'w' )

  # Example Response: (all units are in gallons for this site)
  #   {  
  #    "meta":{  
  #       "access":true,
  #       "hmac":true,
  #       "success":true,
  #       "request":{  
  #          "range_start":"2014-06-01",
  #          "range_end":"2014-07-25",
  #          "interval":"w",
  #          "controller_id":[  
  #             "794",
  #             "750"
  #          ],
  #          "zone_number":null,
  #          "timestamp":"1407506612",
  #          "action":"usage",
  #          "controller":"api/v2/reports_sites",
  #          "id":"157",
  #          "format":"json",
  #          "reports_site":{  

  #          }
  #       },
  #       "message":null
  #    },
  #    "result":{  
  #       "site":{  
  #          "id":157,
  #          "name":"Engineering Dept",
  #          "controllers":[  
  #             {  
  #                "id":750,
  #                "name":"Andey's",
  #                "usage":[  
  #                   {  
  #                      "gallons":1512,
  #                      "date":"2014-06-02"
  #                   },
  #                   {  
  #                      "gallons":1454,
  #                      "date":"2014-06-09"
  #                   },
  #                   {  
  #                      "gallons":1240,
  #                      "date":"2014-06-16"
  #                   },
  #                   {  
  #                      "gallons":1620,
  #                      "date":"2014-06-23"
  #                   },
  #                   {  
  #                      "gallons":1582,
  #                      "date":"2014-06-30"
  #                   },
  #                   {  
  #                      "gallons":1217,
  #                      "date":"2014-07-07"
  #                   },
  #                   {  
  #                      "gallons":1357,
  #                      "date":"2014-07-14"
  #                   },
  #                   {  
  #                      "gallons":454,
  #                      "date":"2014-07-21"
  #                   }
  #                ]
  #             },
  #             {  
  #                "id":794,
  #                "name":"Plan-Id Test - 1 year basic",
  #                "usage":[  
  #                   {  
  #                      "gallons":8306,
  #                      "date":"2014-06-02"
  #                   },
  #                   {  
  #                      "gallons":9015,
  #                      "date":"2014-06-09"
  #                   },
  #                   {  
  #                      "gallons":8068,
  #                      "date":"2014-06-16"
  #                   },
  #                   {  
  #                      "gallons":8564,
  #                      "date":"2014-06-23"
  #                   },
  #                   {  
  #                      "gallons":8693,
  #                      "date":"2014-06-30"
  #                   },
  #                   {  
  #                      "gallons":7871,
  #                      "date":"2014-07-07"
  #                   },
  #                   {  
  #                      "gallons":5892,
  #                      "date":"2014-07-14"
  #                   },
  #                   {  
  #                      "gallons":949,
  #                      "date":"2014-07-21"
  #                   }
  #                ]
  #             }
  #          ]
  #       }
  #    }
  # }

  def site_usage(params)
    data = URI.encode_www_form({
                      "range_start" => params[:range_start], 
                      "range_end" => params[:range_end], 
                      "interval" => params[:interval],
                      "controller_id[]" => params[:controller_id],
                      "zone_number" => params[:zone_number],
                      "timestamp" => Time.now.to_i.to_s
                    })
    uri = parse_uri(@base_uri+"/api/v2/reports/sites/"+params[:site_id].to_s+"/usage.json?" + data)
    @request = make_get(uri)
    make_request(uri,@request)
  end

  # Example
  # params[:site_id] should be the integer value of the site for which you would like weather data
  # params[:range_start] should be passed as 'YYYY-MM-DD' as the start date (on and after) you would like a usage report from
  # params[:range_end] should be passed as 'YYYY-MM-DD' as the end date (on and before) you would like the usage report from
  # params[:interval] *optional* w = Weekly Intervals, m = Monthly Intervals, y = Yearly Intervals.  AVERAGE of the usage by Interval passed
  # params[:controller_id] *optional* pass a specific controller ID or an array of controller IDs with the request to get controller usage instead of entire SITE usage

  # Usage wm.site_weather(:site_id => 157, :controller_id => [699,700], :range_start => "2014-01-01", :range_end => "2014-03-30", :interval => 'w')

  #   {
  #    "meta":{
  #       "access":true,
  #       "hmac":true,
  #       "success":true,
  #       "message":nil,
  #       "request":{
  #          "range_start":"2014-01-01",
  #          "range_end":"2014-03-30",
  #          "interval":"w",
  #          "controller_id":[
  #             "699",
  #             "700"
  #          ],
  #          "timestamp":"1407274155",
  #          "action":"weather",
  #          "controller":"api/v2/reports_sites",
  #          "id":"157",
  #          "format":"json",
  #          "reports_site":{

  #          }
  #       }
  #    },
  #    "result":{
  #       "site":{
  #          "id":157,
  #          "name":"Engineering Dept",
  #          "controllers":[
  #             {
  #                "id":699,
  #                "name":"My Controller",
  #                "location":"Desk",
  #                "weather":[
  #                   {
  #                      "date":"2014-01-01",
  #                      "high":0,
  #                      "low":-2
  #                   },
  #                   {
  #                      "date":"2014-01-05",
  #                      "high":17,
  #                      "low":-3
  #                   },
  #                   {
  #                      "date":"2014-01-12",
  #                      "high":20,
  #                      "low":9
  #                   }
  #                ]
  #             },
  #             {
  #                "id":700,
  #                "name":"Another Controller",
  #                "location":"Other Desk",
  #                "weather":[
  #                   {
  #                      "date":"2014-01-01",
  #                      "high":19,
  #                      "low":16
  #                   },
  #                   {
  #                      "date":"2014-01-05",
  #                      "high":22,
  #                      "low":22
  #                   },
  #                   {
  #                      "date":"2014-01-12",
  #                      "high":22,
  #                      "low":21
  #                   }
  #                ]
  #             }
  #          ]
  #       }
  #    }
  # }

  def site_weather(params)
    data = URI.encode_www_form({
                      "range_start" => params[:range_start], 
                      "range_end" => params[:range_end], 
                      "interval" => params[:interval],
                      "controller_id[]" => params[:controller_id],
                      "timestamp" => Time.now.to_i.to_s
                    })
    uri = parse_uri(@base_uri+"/api/v2/reports/sites/"+params[:site_id].to_s+"/weather.json?"+data)
    @request = make_get(uri)
    make_request(uri,@request)
  end

  # Example
  # params[:range_start] should be passed as 'YYYY-MM-DD' as the start date (on and after) you would like a usage report from
  # params[:range_end] should be passed as 'YYYY-MM-DD' as the end date (on and before) you would like the usage report from
  # params[:interval] *optional* w = Weekly Intervals, m = Monthly Intervals, y = Yearly Intervals.  SUM of the usage by Interval passed
  # params[:controller_id] *optional* pass a specific controller ID or an array of controller IDs with the request to get controller usage instead of entire SITE usage
  # params[:zone_number] *optional* pass a specific zone number or an array of zone numbers with the request to get zone usage instead of entire SITE usage (DEPENDS ON SINGLE CONTROLLER ID ALSO BEING PASSED)

  # Usage wm.site_events(:site_id => 157, :controller_id => [699,700], :zone_number => [1,2], :range_start => "2013-12-01", :range_end => "2013-12-30")
  # This also works: wm.site_events(:site_id => 157, :controller_id => [699], :range_start => "2013-12-01", :range_end => "2013-12-05")

  #   {  
  #    "meta":{  
  #       "access":true,
  #       "hmac":true,
  #       "success":true,
  #       "request":{  
  #          "range_start":"2013-12-01",
  #          "range_end":"2013-12-30",
  #          "interval":null,
  #          "controller_id":[  
  #             "699",
  #             "700"
  #          ],
  #          "zone_number":[  
  #             "1",
  #             "2"
  #          ],
  #          "timestamp":"1407505556",
  #          "action":"events",
  #          "controller":"api/v2/reports_sites",
  #          "id":"157",
  #          "format":"json",
  #          "reports_site":{  

  #          }
  #       },
  #       "message":null
  #    },
  #    "result":{  
  #       "site":{  
  #          "id":157,
  #          "name":"Engineering Dept",
  #          "controllers":[  
  #             {  
  #                "id":699,
  #                "name":"Super Roamer",
  #                "zones":[  
  #                   {  
  #                      "zone_number":1,
  #                      "name":null,
  #                      "events":[  
  #                         {  
  #                            "id":5800,
  #                            "date":"2013-12-18T15:38:13Z",
  #                            "status":1,
  #                            "created_at":"2013-12-18T15:38:13Z",
  #                            "updated_at":"2014-08-08T13:45:08Z",
  #                            "description":"Changed From None to Normal",
  #                            "event_type":699,
  #                            "is_fault":10
  #                         },
  #                         {  
  #                            "id":6014,
  #                            "date":"2013-12-25T09:13:16Z",
  #                            "status":1,
  #                            "created_at":"2013-12-25T09:13:16Z",
  #                            "updated_at":"2014-08-08T13:45:10Z",
  #                            "description":"Changed From Freeze to Normal",
  #                            "event_type":699,
  #                            "is_fault":10
  #                         }
  #                      ]
  #                   },
  #                   {  
  #                      "zone_number":2,
  #                      "name":null,
  #                      "events":[  
  #                         {  
  #                            "id":5956,
  #                            "date":"2013-12-23T09:25:14Z",
  #                            "status":1,
  #                            "created_at":"2013-12-23T09:25:14Z",
  #                            "updated_at":"2014-08-08T13:45:09Z",
  #                            "description":"Changed From Normal to Freeze",
  #                            "event_type":699,
  #                            "is_fault":10
  #                         },
  #                         {  
  #                            "id":6161,
  #                            "date":"2013-12-30T11:13:09Z",
  #                            "status":1,
  #                            "created_at":"2013-12-30T11:13:09Z",
  #                            "updated_at":"2014-08-08T13:45:11Z",
  #                            "description":"Changed From Normal to Freeze",
  #                            "event_type":699,
  #                            "is_fault":10
  #                         }
  #                      ]
  #                   }
  #                ]
  #             },
  #             {  
  #                "id":700,
  #                "name":"TMOB",
  #                "zones":[  
  #                   {  
  #                      "zone_number":1,
  #                      "name":null,
  #                      "events":[  
  #                         {  
  #                            "id":1,
  #                            "date":"2013-12-18T15:38:13Z",
  #                            "status":0,
  #                            "created_at":"2013-12-18T15:38:13Z",
  #                            "updated_at":"2014-08-08T13:44:42Z",
  #                            "description":"Changed Could not establish connection to Zone 4",
  #                            "event_type":700,
  #                            "is_fault":null
  #                         },
  #                         {  
  #                            "id":2,
  #                            "date":"2013-12-18T16:38:13Z",
  #                            "status":0,
  #                            "created_at":"2013-12-18T16:38:13Z",
  #                            "updated_at":"2014-08-08T13:44:42Z",
  #                            "description":"Changed Could not establish connection to Zone 4",
  #                            "event_type":700,
  #                            "is_fault":null
  #                         },
  #                         {  
  #                            "id":3,
  #                            "date":"2013-12-18T17:38:13Z",
  #                            "status":0,
  #                            "created_at":"2013-12-18T17:38:13Z",
  #                            "updated_at":"2014-08-08T13:44:42Z",
  #                            "description":"Changed Could not establish connection to Zone 4",
  #                            "event_type":700,
  #                            "is_fault":null
  #                         }
  #                      ]
  #                   },
  #                   {  
  #                      "zone_number":2,
  #                      "name":null,
  #                      "events":[  
  #                         {  
  #                            "id":4,
  #                            "date":"2013-12-18T18:38:13Z",
  #                            "status":1,
  #                            "created_at":"2013-12-18T18:38:13Z",
  #                            "updated_at":"2014-08-08T13:44:42Z",
  #                            "description":"Changed Could not establish connection to Zone 4",
  #                            "event_type":700,
  #                            "is_fault":null
  #                         },
  #                         {  
  #                            "id":5,
  #                            "date":"2013-12-18T19:38:13Z",
  #                            "status":0,
  #                            "created_at":"2013-12-18T19:38:13Z",
  #                            "updated_at":"2014-08-08T13:44:42Z",
  #                            "description":"Changed Could not establish connection to Zone 4",
  #                            "event_type":700,
  #                            "is_fault":null
  #                         },
  #                         {  
  #                            "id":6,
  #                            "date":"2013-12-18T20:38:13Z",
  #                            "status":1,
  #                            "created_at":"2013-12-18T20:38:13Z",
  #                            "updated_at":"2014-08-08T13:44:42Z",
  #                            "description":"Changed Could not establish connection to Zone 4",
  #                            "event_type":700,
  #                            "is_fault":null
  #                         }
  #                      ]
  #                   }
  #                ]
  #             }
  #          ]
  #       }
  #    }
  # }

  def site_events(params)
    data = URI.encode_www_form({
                      "range_start" => params[:range_start], 
                      "range_end" => params[:range_end], 
                      "interval" => params[:interval],
                      "controller_id[]" => params[:controller_id],
                      "zone_number[]" => params[:zone_number],
                      "timestamp" => Time.now.to_i.to_s
                    })
    uri = parse_uri(@base_uri+"/api/v2/reports/sites/"+params[:site_id].to_s+"/events.json?"+data)
    @request = make_get(uri)
    make_request(uri,@request)
  end

  
  private
  
  # This is the generic request - it cannot be called directly
  def make_request(uri,request)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @request = request
    data = @request.method.eql?('GET') ? uri.query : @request.body
    @request["Accept"] = "application/json"
    @request["Content-Type"] = "application/json"
    @request['x-api-hmac'] = generate_hmac_string(data)
    @request["x-api-key"] = api_key
    @request.basic_auth(username,password)
    # puts "request headers are " + @request.to_hash.to_s
    # puts "request body is " + @request.body.inspect
    response = @http.request(@request)
    return JSON.parse(response.body)
    # puts JSON.parse(response.body)
  end

  def parse_uri(uri)
    URI.parse(uri)
  end

  def generate_hmac_string(data)
    key = secret_api_key
    digest = OpenSSL::Digest.new('sha256')
    hmac = OpenSSL::HMAC.digest(digest, key, data)
    hmac = Base64.encode64(hmac).strip()
    return hmac
  end

  def api_key
    ENV['SLN_API_KEY']
    # '998174b6f911b8e95db1c15d1ac59c4f' # This should be an environment variable for best security - this is not a production key
  end

  def secret_api_key
    ENV['SLN_API_SECRET_KEY']
    # '245aa67451c534803dc93e7953ff40b6' # This should be an environment variable for best security - this is not a production key
    # '245aa67451c534803dc93e7953ffffff'
  end

  def make_get(uri)
    Net::HTTP::Get.new(uri.request_uri)
  end

  def make_post(uri)
    Net::HTTP::Post.new(uri.request_uri)
  end

  def add_timestamp
    'timestamp='+Time.now.to_i.to_s
  end

end