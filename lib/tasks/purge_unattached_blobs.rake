# rake active_storage:purge_unattached DAYS=2
namespace :active_storage do
  desc "Purges unattached ActiveStorage::Blobs older than the specified number of days. Defaults to purging all unattached blobs if no days are specified."
  task purge_unattached: :environment do
    # Retrieve the 'days' argument from the environment variables
    days = ENV["DAYS"]&.to_i

    # Determine the scope of blobs to purge based on the 'days' argument
    blobs_to_purge = if days
                       # Purge blobs older than the specified number of days
                       ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at < ?", days.days.ago)
    else
                       # Purge all unattached blobs
                       ActiveStorage::Blob.unattached
    end

    # Count the number of blobs to be purged
    blob_count = blobs_to_purge.count

    if blob_count > 0
      # Purge each blob asynchronously
      blobs_to_purge.find_each(&:purge_later)
      puts "Scheduled #{blob_count} unattached blob(s) for purging."
    else
      puts "No unattached blobs found for the specified criteria."
    end
  end
end
