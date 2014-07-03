require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
    attr_reader :client

    def initialize
        puts "Initializing"
        @client = JumpstartAuth.twitter
    end

    def shorten(original_url)
        bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
        puts "Shortening this URL: #{original_url}"
        bitly.shorten(original_url).short_url
    end

    def tweet(message)
        if message.length <= 140
            @client.update(message)
        else
            puts "Too long!"
        end
    end

    def dm(target, message)
        puts "Trying to send #{target} this direct message:"
        puts message

        if followers_list.include?(target)
            str = "d #{target} #{message}"
            tweet(str)
        else
            puts "You can only DM your followers!"
        end
    end

    def followers_list
        screen_names = @client.followers.collect{|follower| follower.screen_name}
    end

    def spam_my_followers(message)
        followers = followers_list
        followers.each { |f| dm(f, message) }
    end

    def everyones_last_tweet
        friends = @client.friends
        friends.each do |friend|
            tstamp = friend.status.created_at
            puts "#{friend.screen_name} said the following on #{tstamp.strftime("%A, %b %d")}... #{friend.status.text}"
            puts " "
        end
    end

    def run
        puts "Welcome to the JSL Twitter Client!"
        command = ""

        while command != "q"
            puts ""
            printf "enter command: "
            input = gets.chomp
            parts = input.split
            command = parts[0]

            case command
                when 'q' then puts "Goodbye!"
                when 't' then tweet(parts[1..-1].join(" "))
                when 'dm' then dm(parts[1], parts[2..-1].join(" "))
                when 'spam' then spam_my_followers(parts[1..-1].join(" "))
                when "elt" then self.everyones_last_tweet
                when 's' then shorten(parts[1..-1].join)
                when 'turl' then tweet(parts[1..-2].join(' ') + ' ' + shorten(parts[-1]))
                else
                    puts "Sorry, I don't know how to #{command}"
                end

        end
    end
end

blogger = MicroBlogger.new
blogger.run
