#!/usr/bin/env ruby

require 'rubygems'

def install_gem(name, version=Gem::Requirement.default)
  begin
    gem name, version
  rescue LoadError
    print "ruby gem '#{name}' not found, " <<
	  "would you like to install it (y/N)? : "
	answer = gets
	if answer[0].downcase.include? "y"
	  Gem.install name, version
	else
	  exit(1)
	end
  end
end

install_gem 'droplet_kit'

require 'net/http'
require 'droplet_kit'

my_ip = Net::HTTP.get URI 'http://bot.whatismyipaddress.com'
puts "Your ip is #{my_ip}"

unless my_ip.nil? or my_ip.empty?
  digitalocean_access_token = ENV['DIGITALOCEAN_ACCESS_TOKEN']
  firewall_id = ENV['DIGITALOCEAN_FIREWALL_ID']
  unless digitalocean_access_token.nil? or digitalocean_access_token.empty? or
    firewall_id.nil? or firewall_id.empty?
    client = DropletKit::Client.new(access_token: digitalocean_access_token)
	inbound_rule = DropletKit::FirewallInboundRule.new(
	  protocol: 'tcp',
	  ports: '8388',
	  sources: {
	    addresses: [my_ip]
	  }
	)
	client.firewalls.add_rules(inbound_rules: [inbound_rule], id: firewall_id)
	puts "Finished!"
  end
end