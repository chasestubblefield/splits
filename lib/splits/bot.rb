require 'cinch'
require 'cinch/plugins/identify'

class Splits
  class Bot
    def initialize(channel, splits, nick, password)
      @bot = Cinch::Bot.new do

        configure do |c|
          c.server = 'irc.speedrunslive.com'
          c.channels = [channel]
          c.nick = nick
          if password
            c.plugins.plugins = [Cinch::Plugins::Identify]
            c.plugins.options[Cinch::Plugins::Identify] = {
              :password => password,
              :type     => :nickserv,
            }
          end

          # Quiet cinch output
          @loggers = Cinch::LoggerList.new
          @splitbot_connected = false
          @splitbot_race_started = false
        end

        on :connect do
          synchronize(:splitbot_connected) do
            @bot.instance_variable_set(:@splitbot_connected, true)
          end
        end

        on :channel, "GO!" do |m|
          if m.user.to_s =~ /RaceBot/
            splits.start!
            synchronize(:splitbot_race_started) do
              @bot.instance_variable_set(:@splitbot_race_started, true)
            end
          end
        end

        on :sb_enter do
          Channel(channel).send('.enter')
          synchronize(:splitbot_entered) do
            @bot.instance_variable_set(:@splitbot_entered, true)
          end
        end

        on :sb_ready do
          Channel(channel).send('.ready')
        end

        on :sb_time do |msg, split|
          Channel(channel).send(".time #{split}")
        end

        on :sb_done do
          Channel(channel).send(".done")
        end
      end
    end

    %w(connected race_started).each do |m|
      define_method "#{m}?" do
        @bot.synchronize("splitbot_#{m}".to_sym) do
          @bot.instance_variable_get("@splitbot_#{m}".to_sym)
        end
      end
    end

    def start!
      print "Connecting IRC bot..."
      @bot_thread = Thread.new do
        @bot.start
      end
      until connected?
        sleep 2
        print '.'
      end
      puts
    end

    def enter!
      @bot.handlers.dispatch(:sb_enter)
    end

    def ready!
      @bot.handlers.dispatch(:sb_ready)
      print 'Waiting for go...'
      until race_started?
        sleep 2
        print '.'
      end
      puts
    end

    def split!(split)
      @bot.handlers.dispatch(:sb_time, nil, split)
    end

    def done!
      @bot.handlers.dispatch(:sb_done)
    end

  end
end
