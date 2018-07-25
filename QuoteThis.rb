# Require 'net/http' to allow the Object to download webpage to later parse the stock price

require 'net/http'
require 'twilio-ruby'

# Establish the class that will create and modify a stock object

class Stock
	
	# It is not necessary to declare this module in the class as it is already 'called' into the 'http' included file
	# but I like to remind myself that I am using a mixin within a class method
	
	module URI
	end
	 
	# These values need to be accessable to the different methods throughout the class
	
	attr_accessor :symbol, :quote, :number, :final_quote, :mess
	 
	# This method brings the stock symbol value from 'gets' into the class for use in the methods
	
	def initialize(symbol)
		
		if symbol == "" || nil then
			raise ArgumentError, "Must enter a valid symbol"
		else
			@symbol = symbol
		end
		
	end
	
	# Using the URI module here to pull a webpage off the internet and assign it to '@quote' as a string
	
	def download_webpage
		
			uri = URI('http://www.nasdaq.com/symbol/' + @symbol + '/real-time')
			@quote = Net::HTTP.get(uri)
		
	end
	
	# This is where I use a regexp to find the price of the symbol.
	# Had to read the html of the webpage and find the combination of characters that indicate the price.
	# In this case the quote is always proceeded by "\>$" so I search for that combo of characters and then a price which is \d+\.\d+
	# The first element in the array is the price I'm looking for..
	
	def scan_quote
		
		stock_price = @quote.scan(/\W\W\W\d+\.\d+/i)
		@number = stock_price[0]
		
	end
	
	# In order to make the price presentable I have to delete the extra characters at the beginning of the price.
	
	def format_quote
		
		@final_quote = @number.delete('"\">$')
		return @final_quote
	end
	
	# Returns the 'formatted' price of the stock symbol.
	
	def worth
		
		@mess =  "This stock is currently trading at: $#{@final_quote}"
		space = "\n"
		return space + @mess 
		
	end
	
end
		
	def start
	print "Enter a symbol to lookup: "
		
		stock_to_lookup = Stock.new(gets.chomp!.to_s.downcase)
		
	stock_to_lookup.download_webpage
	stock_to_lookup.scan_quote
	stock_to_lookup.format_quote
	puts stock_to_lookup.worth
end

	# Basic information needed to communicate with Twilio SMS server and send a message
	secretfunction = <<-END
	account_sid = "GetTokenFromFile" 
	auth_token = "GetTokenFromFile"
			
	@client = Twilio::REST::Client.new account_sid, auth_token
	
			
	message = @client.account.messages.create(
									:body => stock_to_lookup.worth,
									:to => "+MyPhoneNumber",
									:from => "TwilioSmsNumber")
	
	puts message.sid
END

loop do
	puts %q^Please select an option:
	
	1. Lookup a stock symbol
	2. Exit program^ 
	
	case gets.chomp
	
	when '1'
	start
	
	when '2'
	exit
	
	end
end

# Add p/e ratio, eps, and price to book ratio capability and more stock analysis ability