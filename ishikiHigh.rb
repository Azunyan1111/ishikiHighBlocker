require "twitter"
require "csv"

@keywords = CSV.read("keywords.csv")
@blocked_accounts = CSV.read("block_list.csv")

@twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_SECRET']
  config.access_token        = ENV['OAUTH_TOKEN']
  config.access_token_secret = ENV['OAUTH_SECRET']
end

def filter_ishiki_takai_followers(id)
  client = @twitter_client
  ishiki_takai_accounts = []
  client.follower_ids(id).each_slice(100).each do |slice|
    client.users(slice).each do |f|
      account = {:id => f.id, :name => f.screen_name, :desc => f.description}
      ishiki_takai_accounts << account if ishiki_takai?(account) && !blocked?(account)
    end
  end
  ishiki_takai_accounts
end

# もっといい感じに書き直したい..
def ishiki_takai? (account)
  points = 0
  @keywords.each do |kw|
    points += kw[1].to_i if account[:desc].include?(kw[0])
  end
  return points >= 5
end

def blocked? (account)
  return @blocked_accounts.include?([account[:id].to_s])
end

def write_csv(id)
  CSV.open("block_list.csv", "a") do |file|
    file << [id]
  end
end

target = ARGV[0]
filter_ishiki_takai_followers(target).each do |f|
  # TODO: FF内かどうかチェックしてからblock
   @twitter_client.block(f[:id])
  write_csv(f[:id])
  puts "blocked #{f[:name]}"
end
