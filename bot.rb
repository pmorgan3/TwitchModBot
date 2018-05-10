require 'socket'


TWITCH_HOST = "irc.twitch.tv"

#The default irc port for twitch
TWITCH_PORT = 6667

class TwitchBot

    def initialize
        #instance variables
        #nickname
        @nickname = "YOUR_NICKNAME_HERE"
        #oath token
	#you get your oath token by going to twitchapp.com/tmi and copying the key
	#it gives you
        @password = "YOUR_OATH_TOKEN_HERE"
        #channel of twitch account
	#for example, type "ninja" if you're going to ninja's channel
        @channel = "YOUR_CHANNEL_HERE"
        @socket = TCPSocket.open(TWITCH_HOST, TWITCH_PORT)

        #Set up the irc connection
        write_to_system "PASS #{@password}"
        write_to_system "NICK #{@nickname}"
        write_to_system "USER #{@nickname} 0 * #{@nickname}"
        write_to_system "JOIN ##{@channel}"
    end

    def write_to_system(message)
        @socket.puts message
    end

    def write_to_chat(message)
        write_to_system "PRIVMSG ##{@channel} :#{message}"
    end

    def run 
        until @socket.eof? do
            message = @socket.gets
            puts message

            #some regex
            if message.match(/PRIVMSG ##{@channel} :(.*)$/)
                #content is the message that twitch users put in chat
		content = $~[1]
		#username is the name of the user that sent that message
                username = message.match(/@(.*).tmi.twitch.tv/)[1]

		#You should edit these to suit your needs.
		#This is an example of the bot responding to a Command
                if content.include? "*bots" or content.include? "*bot"
                    write_to_chat("I thought I put these bots on hard.")
                end

		#This is an example of the bot performing an action based on
		#a trigger word.
		#
                if content.include? "leveled is better"
                    puts username
                    write_to_chat("/timeout #{username} 800")
                end

            end
        end
    end

end

bot = TwitchBot.new
bot.run
