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

if my_ip.nil? or my_ip.empty?
  puts "Failed to get my ip"
else
  puts "Your ip is #{my_ip}"

  digitalocean_access_token = ENV['DIGITALOCEAN_ACCESS_TOKEN']
  if digitalocean_access_token.nil? or digitalocean_access_token.empty?
    puts "Access token not found"
  else
    client = DropletKit::Client.new(access_token: digitalocean_access_token)
    
    if client.nil?
      puts "Failed to create DropletKit client"
    else
      firewall_name = ENV['DIGITALOCEAN_FIREWALL_NAME']
      if firewall_name.nil? or firewall_name.empty?
        puts "Firewall name not found"
      else
        firewall = nil
        firewalls = client.firewalls.all
        firewalls = firewalls.select do |fw|
          fw.name == firewall_name
        end
        if firewalls.length > 0
          firewall = firewalls.first
        end
        
        if firewall.nil?
          puts "Failed to get the firewall with specified name"
        else
          firewall_id = firewall.id
          puts "Firewall id is #{firewall_id}"
          
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
    end
  end
end
