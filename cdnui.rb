require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require 'thin'
require 'dynect_rest'
require 'yaml'
require 'cdncontrol/trafficmanager'

class CDNUi < Sinatra::Base

  # Comment out the following 3 lines if you want more verbose logging
  # like stacktraces and the dev mode sinatra error page
  #set :show_exceptions, false
  #set :logging, false
  #set :dump_errors, false


  before do
    @settings = YAML.load_file("/usr/local/etc/cdncontrol.conf")
    @valid_providers = @settings["valid_providers"]
    @valid_modes = @settings["valid_modes"] || [ "always", "obey", "remove", "no" ]
  end

  configure do
    enable :sessions
  end

  # Base route
  get '/' do
    @targets = @settings["targets"].keys
    haml :index
  end

  get '/zoneweights' do
    @zone = params["zone"]
    @zone_data = @settings["targets"][@zone]
    @username = request.env["HTTP_X_USERNAME"]
    if @settings['eventinator_server']
      require 'eventinator-client'
    end
    tm =  CDNControl::TrafficManager.new(@settings,@zone_data, false)
    tm.set_user(@username)
    @weights = Hash.new
    tm.get_weights.to_a.first.last.select{|k,v|@valid_providers.include?(k)}.each do |k,v|
      @weights[k] = {
                      :weight => v["weight"],
                      :serve_mode => v["serve_mode"]
                    }
    end
    total_weights = @weights.values.map{|v|v[:weight]}.inject(:+)
    @adjusted_weights = Hash.new
    @weights.each{|k,v|@adjusted_weights[k] = {:weight => ((v[:weight].to_f / total_weights) * 100).round(1), :serve_mode => v[:serve_mode]}}
    haml :zoneweights, :layout => false
  end

  post '/savechange' do

    #Check referer and 403 if not from the app
    referer = request.env["HTTP_REFERER"] || ""
    @username = request.env["HTTP_X_USERNAME"]
    if @settings["cdncontrol_ui_hostname"]
      unless  referer.include?("http://localhost:3000/") || referer.include?(@settings["cdncontrol_ui_hostname"])
        halt 403
      end
    else
      unless  referer.include?("http://localhost:3000/")
        halt 403
      end
    end


    #Get params and bork if any are missing
    zone = params["zone"]
    change = params["type"]
    param_string = params["params"].split(",")
    param_cdn = param_string.first
    param_value = param_string.last
    unless !zone.nil? and !change.nil? and !param_cdn.nil? and !param_value.nil?
      halt 500
    end

    #Create helper
    zone_data = @settings["targets"][zone]
    if @settings['eventinator_server']
      require 'eventinator-client'
    end
    tm =  CDNControl::TrafficManager.new(@settings,zone_data, false)
    tm.set_user(@username)

    #Check what change type, then make changes
    if change == "weight"
      tm.set_weight(param_cdn,param_value,false)
    elsif change == "mode"
      tm.set_serve_mode(param_cdn,param_value,false)
    else
      halt 500
    end
    tm.dump_weights(zone,@settings["output_path"])
    haml :savechange
  end

  not_found do
    haml :'404'
  end

  error do
    @error = "#{request.env['sinatra.error'].to_s}"
    haml :'500'
  end
end