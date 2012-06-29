#filescandir.rb

require 'rubygems'
require 'fileutils'

##
# scan the root dir and create a list of all files in it
class FileScanDir
  attr_accessor :result_list, :dir_list, :is_silent, :simulate  

  def initialize
    @explore_dir = []
    @filter_dir = []
    @result_list = []
    @filter_file = []
    @filter_extension = []
    @dir_list = []
    @is_silent = false
    @simulate = false
  end
  
  def log(str)
    puts str if !@is_silent
  end
  
 
  ##
  # Add an array of directories to be filtered
  def add_dir_filter(filter)
    @filter_dir = filter
  end
  
  def add_extension_filter(filter)
    @filter_extension = filter
  end
  
  ##
  # Add an array of file that don't belong to the list
  def add_file_filter(file_filter)
    @filter_file = file_filter
  end
  
  ##
  # Scan a root dir and list all files. Exclude filtered directory
  def scan_dir (dirname)
    log "*** Inspect: " + dirname
    Dir.foreach(dirname) do |filename|
      path_cand = File.join(dirname , filename)
      if File.directory?(path_cand)
        #exams directories
        if (filename != "." && filename != "..")
          unless @filter_dir.index(filename)
            #directory not filtered
            @explore_dir.push(path_cand)
            @dir_list << path_cand
          end
        end
      else
        # file to be listed
        unless file_is_filtered?(path_cand)
          # file is not filtered
          @result_list.push(path_cand)
        end
      end #file.directory?
    end
    next_dir = @explore_dir.pop
    scan_dir(next_dir) if next_dir 
  end # end scan dir
  
  ##
  # Check if a file belongs to a filtered list
  def file_is_filtered?(path_cand)
    filename = File.basename(path_cand)
    extname = File.extname(filename)
    ix_ext = @filter_extension.index(extname)
    ix = @filter_file.index(filename)
    if ix or ix_ext
      log "FILTER: #{path_cand}" 
      return true
    else
      return false
    end
  end
  
  ##
  # Write the list into a file
  def write_filelist(out_file_list)
    result_list.each{|f| log f}
    File.open(out_file_list, "w") do |file|
        result_list.each do |item| 
        file << item
        file << "\n"
      end
      log "File list created #{out_file_list}"
    end 
  end
  
  ##
  # Copy src file list in to destination directory
  # file_list: file list with complete path
  # start_dir: directory root on source
  # dst_dir: full path of destination directory
  def copy_appl_to_dest(file_list, start_dir, dst_dir)
    num_of_files = 0
    file_list.each do |src_file|
      # name without start_dir
      rel_file_name = src_file.gsub(start_dir, "")
      log "Copy #{rel_file_name}"
      # calculate destination name
      dest_name_full = File.join(dst_dir, rel_file_name)
      dir_dest = File.dirname(dest_name_full)
      num_of_files = num_of_files + 1
      # make sure that a directory destination exist because cp don't create a new dir
      if !@simulate
        FileUtils.mkdir_p(dir_dest) unless File.directory?(dir_dest)
        FileUtils.cp(src_file, dest_name_full)
      end
    end
    log "Num of files copied #{num_of_files}"
  end
   
end#end class FileScanDir
