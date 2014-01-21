require 'logger'
$l = Logger.new STDOUT
$l.datetime_format = '%Y-%m-%d %H:%M:%S '

require_relative 'file_mover'

class Main

  $l.debug "From: #{$FROM_DIR}"
  $l.debug "To: #{$TO_DIR}"

  fm = FileMover.new $FROM_DIR, $TO_DIR
  fm.copy_snaps

end



if $0 == __FILE__
  Main.new
end