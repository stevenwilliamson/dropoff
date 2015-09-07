require "date"
require "fileutils"

# Class that encapsulates a few methods for handling
# the saving of log files from remote systems in a safe
# manner
class LogVault
  DEFAULT_FORMAT_STRING="/data/@host/%Y/%m/%d"

  # Sets the destination files will be stored
  # You can use placeholders:
  # @host - the host the file is from
  # And any % values expected by strftime
  def destination_format_string=(format_string)
    @destination_format_string = format_string
  end

  def destination_format_string
    @destination_format_string
  end

  # Returns the destination path with placeholders
  # replaced
  # var_hash is a hash of variable name => value
  # though at this point in time we only support
  # as a placeholder @host.
  def destination(var_hash)
    date = DateTime.now()
    if @destination_format_string
      format_string = @destination_format_string
    else
      format_string = DEFAULT_FORMAT_STRING
    end
    date.strftime(format_string.gsub("@host", var_hash['host']))
  end

  # Calculates the file name we use to store it
  # which will be:
  # <SHA256>_originalfilename
  # This ensures that if a file is uploaded twice with the same timeframe
  # if the file has changed we will store both.
  # For instance an attacker could otherwise game the system and upload a file
  # of the same name of the real log file first, preventing the real one been uploaded.
  # This is a really cheap content addressable file system in a fasion.
  # a change in content will always result in a new file.
  def calculate_file_name(file_path,file_name)
   file_sha = Digest::SHA256.file(file_path)
   "#{file_sha}_#{file_name}"
  end

  # Store a file in the destination directory
  # and calculate it's name based on the content.
  def save(sourcepath, filename, host)
    saved_file_name = calculate_file_name(sourcepath, filename)
    destination_path = destination('host' => host)

    # The path is set dynamically based on host name and time
    # make sure it exists if not create it
    FileUtils.mkdir_p(destination_path) unless Dir.exists?(destination_path)

    File.rename(sourcepath, File.join(destination_path, saved_file_name))
  end

end
