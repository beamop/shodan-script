#!/usr/bin/env ruby

require 'shodan'
require 'colorize'
require 'terminal-table'
require 'date'
require 'fileutils'

##############################
# Your Shodan API KEY
##############################
api_key = 'VsrdI0B48xCBwhlMSrv5GaZUtOua3qsy'

# banner
def banner
	puts "
	███████╗██╗  ██╗ ██████╗ ██████╗  █████╗ ███╗   ██╗      ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗
	██╔════╝██║  ██║██╔═══██╗██╔══██╗██╔══██╗████╗  ██║      ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝
	███████╗███████║██║   ██║██║  ██║███████║██╔██╗ ██║█████╗███████╗██║     ██████╔╝██║██████╔╝   ██║   
	╚════██║██╔══██║██║   ██║██║  ██║██╔══██║██║╚██╗██║╚════╝╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   
	███████║██║  ██║╚██████╔╝██████╔╝██║  ██║██║ ╚████║      ███████║╚██████╗██║  ██║██║██║        ██║   
	╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝      ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ".red

	puts

	puts "
	beamop 2018.
	still learning ruby, it sucks I know.".yellow

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
rescue Exception => e
	puts 'Error! Please check logs folder.'
	# save errors to logs folder
	d = DateTime.now
	d.strftime("%d/%m/%Y/%H/%M")
	File.open(File.expand_path("logs/error_#{d}.txt"), 'w') {|f| f.write(e.to_s) }
end

