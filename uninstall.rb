
require 'rbconfig'
require 'fileutils'
include RbConfig

FileUtils.mkdir_p(CONFIG["sitearchdir"])

file = CONFIG["sitearchdir"] + "/wiiflashclient.rb"
FileUtils.remove(file, {:verbose => true})

puts "アンインストールされました"

