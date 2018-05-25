require 'socket'
require 'set'

TWITCH_HOST = "irc.twitch.tv"

#The default irc port for twitch
TWITCH_PORT = 6667

class TwitchBot

    def initialize

        user_info = load_user_info
        #instance variables
        #nickname
        @nickname = user_info[0]
        #oath token
	#you get your oath token by going to twitchapp.com/tmi and copying the key
	#it gives you
        @password = user_info[1]
        #channel of twitch account
	#for example, type "ninja" if you're going to ninja's channel
        @channel = user_info[2]
        @socket = TCPSocket.open(TWITCH_HOST, TWITCH_PORT)


        @@words = Hash.new

        #Set up the irc connection
        write_to_system "PASS #{@password}"
        write_to_system "NICK #{@nickname}"
        write_to_system "USER #{@nickname} 0 * #{@nickname}"
        write_to_system "JOIN ##{@channel}"
    end

    def load_user_info()
        fileName = "UserInfo.txt"
        user_info = Array.new
        File.open(fileName,"r") do |f|
            f.each_line do |line|
                info = line.gsub("\n",'').gsub(" ",'').partition(':').last
                user_info << info
            end
        end
        puts "#{user_info.to_s}"
        return user_info
    end

    #Loads all words contained in the Words.txt file in the local directory
    def load_words()
        fileName = "Words.txt"
        subject = 'DEFAULT'
        File.open(fileName,"r") do |f|
            f.each_line do |line|
                if line[0,2] == "//"
                    subject = line.gsub("\n",'').split('//')[-1].upcase
                else
                    if !line.to_s.empty?
                        @@words[line.gsub("\n",'')] = subject
                    end
                end
            end
        end
    end

    #Goes through the users message and checks if they wrote something under the search parameters (RACIAL/BAD/BOT) terms
    def content_check(content,username)
        @@words.each do |key, type|
            if content.include? key
                exec_command(type,username)
            end
        end
    end

    def exec_command(type,username)
        case type
        when 'BOT'
            write_to_chat("I thought I put these bots on hard.")
        when 'BAD'
            write_to_chat("/timeout #{username} 800")
        when 'RACIAL'
            write_to_chat("/ban #{username}")
        end
    end

    # automated command that will be typed in chat
    # duration is in SECONDS
    def auto_command(duration)
        Thread.new do
            while true do
                sleep duration
                write_to_chat("This is an automated message.")
            end
        end

    end

    def write_to_system(message)
        @socket.puts message
    end

    def write_to_chat(message)
        write_to_system "PRIVMSG ##{@channel} :#{message}"
    end

    def run
        load_words
        #auto_command(300)
        until @socket.eof? do
            message = @socket.gets
            puts message

            #some regex
            if message.match(/PRIVMSG ##{@channel} :(.*)$/)
                #content is the message that twitch users put in chat
		    content = $~[1]

		    #username is the name of the user that sent that message
            username = message.match(/@(.*).tmi.twitch.tv/)[1]

            #see content_check above
		    content_check(content,username)
            end
        end
    end

end

bot = TwitchBot.new
bot.run
