namespace :ferret do

  # Rebuild index task. Declare the indexes to be rebuilt with the INDEXES
  # environment variable:
  #
  # INDEXES="my_model shared" rake ferret:rebuild
  desc "Rebuild a Ferret index. Specify what model to rebuild with the INDEXES environment variable."
  task :rebuild => :environment do
    if ENV['INDEXES']
      indexes = ENV['INDEXES'].split
      indexes.each do |index_name|
        start = 1.minute.ago
        Rails.application.eager_load! if defined?(Rails)
        ActsAsFerret::rebuild_index index_name
        idx = ActsAsFerret::get_index index_name
        # update records that have changed since the rebuild started
        idx.index_definition[:registered_models].each do |m|
          m.records_modified_since(start).each do |object|
            object.ferret_update
          end
        end
      end
    else
      puts "set the INDEXES environment variable to the index names you want to rebuild:\nINDEXES=\"my_index another_index\" rake ferret:rebuild"
    end
  end
end
