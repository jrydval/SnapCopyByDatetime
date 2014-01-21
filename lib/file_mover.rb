require_relative 'config'
require 'fileutils'
require 'exifr'

class FileMover

  attr_accessor :from_dir, :to_dir

  def initialize from_dir, to_dir

    @from_dir = from_dir
    @to_dir = to_dir

    if File.exists? from_dir
      $l.debug 'Source directory exists'
    else
      $l.fatal 'Source directory doesn\'t exist'
      exit 1
    end

    if File.exists? to_dir
      $l.debug 'Destination directory exists'
    else
      $l.info 'Creating destination directory'
      FileUtils::mkpath to_dir
    end
  end

  def iterate_over_source_snaps
    Dir.glob(File.join(from_dir, '????_????', '*.JPG')).sort.reverse.each do |file|
      $l.info "File processed: #{file}"
      yield file
    end
  end

  def to_copy? file

    dt = EXIFR::JPEG.new(file).date_time
    file_name = File.basename file
    fld_name = dt.strftime '%Y-%m-%d'
    fld_year = dt.year.to_s
    fld_name_mask = fld_name + '*'

    destination_file_mask = File.join(to_dir, fld_year, fld_name_mask, file_name)
    files_found = Dir.glob(destination_file_mask)

    if files_found.empty?
      return File.join to_dir, fld_year, fld_name, file_name
    else
      $l.debug "File at destination found: #{files_found[0]}"
      return false
    end
  end

  def copy_snaps
    iterate_over_source_snaps do |file|
      where = to_copy? file
      if where
        $l.debug "Copying file from #{file} to #{where}"

        FileUtils.mkpath( File.dirname(where) )
        FileUtils::copy_file file, where

      else
        $l.info "Stopping"
        return 0
      end
    end
  end



end