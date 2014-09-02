namespace "instagram-reporter" do

  desc 'get popular instagrammers'
  task :get_popular_instagrammers => :environment do
    #begin
      require 'instagram_reporter'
      InstagramReporter.new
    #rescue Exception => e
      #ExceptionNotifier.notify_exception(e)
    #end
  end

  #desc 'observe hashtag'
  #task :observe_hashtag, [:hashtag] => :environment do |t, args|
    #begin
      #require 'instagram_hashtag_observer'
      #InstagramHashtagObserver.new.get_hashtag_info(args[:hashtag])
    #rescue Exception => e
      #ExceptionNotifier.notify_exception(e)
    #end
  #end

  #desc 'update comments and likes counts on InstagramMediaFiles' 
  #task 'update_comments_and_likes_counts_on_imf' => :environment do
    #begin
      #require 'instagram_hashtag_observer'
      #InstagramMediaFilesObserver.new.get_all_comments_and_likes
    #rescue Exception => e
      #ExceptionNotifier.notify_exception(e)
    #end
  #end

end

