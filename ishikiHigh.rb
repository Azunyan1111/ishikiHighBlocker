require "twitter"
require "csv"

@keywords = CSV.read("keywords.csv")

@twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_SECRET']
  config.access_token        = ENV['OAUTH_TOKEN']
  config.access_token_secret = ENV['OAUTH_SECRET']
end

def get_all_followers(id)
  client = @twitter_client
  all_friends = []
  client.follower_ids(id).each_slice(100).each do |slice|
    client.users(slice).each do |f|
      all_friends << {:id => f.id, :name => f.screen_name, :desc => f.description}
    end
  end
  all_friends
end

# もっといい感じに書き直したい..
def ishikiTakai? (friend)
  points = 0
  @keywords.each do |kw|
    points += kw[1].to_i if friend[:desc].include?(kw[0])
  end
  puts friend[:desc], points
  return points >= 5
end

target = ARGV[0]
get_all_followers(target).each do |f|
  if ishikiTakai?(f)
    @twitter_client.block(f[:id])
    puts "blocked #{f[:name]}"
  end
end
