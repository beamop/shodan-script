#!/usr/bin/env ruby

require 'shodan'
require 'colorize'
require 'terminal-table'
require 'date'
require 'fileutils'

##############################
# Your Shodan API KEY
##############################
api_key = ''

# banner
def banner
	banner = File.read('banner/banner.txt')

	puts banner.yellow

	puts
end

# cls
def cls
	if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
	  system('cls')
	else
	  system('clear')
	end
end

api = Shodan::Shodan.new(api_key)

# create results folder if not exist
unless File.directory?('results')
	FileUtils.mkdir_p('results')
end
# create logs folder if not exist
unless File.directory?('logs')
	FileUtils.mkdir_p('logs')
end

begin
	cls

	# puts banner
	banner

	# choice
	puts "1. Get all the information SHODAN has on IP address.".blue
	puts
	puts "2. Do a simple search using a query name or device name and show them in a table.".blue
	puts
	print "Please enter your choice. ".red
	c1 = gets.chomp.to_i

	# choice 1
	if c1 == 1
		cls 

		print "Enter the IP (eg. 127.0.0.1): ".light_green
		f1 = STDIN.gets.downcase.chomp

		# result
		result = api.host(f1)
		tresult = Terminal::Table.new do |t|
			t.headings = ['index', 'country', 'ip address', 'last update', 'org', 'isp', 'longitude', 'latitude']
			t << ["1", result['country_name'], result['ip_str'], result['last_update'], result['org'], result['isp'], result['longitude'], result['latitude']]
		end

		cls

		puts tresult

		puts
			puts 'Thanks for using my simple demo tool, feel free to contribute.'.blue
		puts

	end

	# choice 2
	if c1 == 2
		cls

		# filters
		print "Enter a query string (eg. cisco-ios): ".light_green
		f1 = STDIN.gets.downcase.chomp

		print "How much IPs do you need (max. 100): ".light_green
		f2 = STDIN.gets.downcase.chomp.to_i

		print "Do you want to save the result to a file? ".light_green
		f3 = gets.chomp
		case f3
			when 'y', 'Y', 'yes'
				f3 = true
			when 'n', 'N', 'no'
				f3 = false
		end

		# result
		result = api.search(f1)
		tresult = Terminal::Table.new do |t|
			t.headings = ['index', 'ip address', 'port', 'org', 'isp']
			result['matches'].first(f2).each_with_index{ |host, index|
				t << ["#{index}", host['ip_str'], host['port'], host['org'], host['isp']]
			}
		end

		cls

		puts tresult

		# save result to file
		if f3 == true
			d = DateTime.now
			d.strftime("%d/%m/%Y/%H/%M")
			File.open(File.expand_path("results/result_#{f1}_#{d}.txt"), 'w') {|f| f.write(tresult) }
			puts
			puts "File saved to 'results/result_#{f1}_#{d}.txt', thanks for using my simple demo tool, feel free to contribute.".blue
			puts
		else
			puts
			puts 'Thanks for using my simple demo tool, feel free to contribute.'.blue
			puts
		end
	end
rescue Exception => e
	puts 'Error! Please check logs folder.'
	# save errors to logs folder
	d = DateTime.now
	d.strftime("%d/%m/%Y/%H/%M")
	File.open(File.expand_path("logs/error_#{d}.txt"), 'w') {|f| f.write(e.to_s) }
end

