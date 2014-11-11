
require 'rbconfig'
require 'fileutils'
include RbConfig

FileUtils.mkdir_p(CONFIG["sitearchdir"])

file_src  =                        "./wiiflashclient.rb"
file_dest = CONFIG["sitearchdir"] + "/wiiflashclient.rb"
FileUtils.install(file_src , file_dest, {:verbose => true, :preserve => true})

puts "インストールされました"

