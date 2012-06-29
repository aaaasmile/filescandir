#file: basic.rb

require '../filescandir'

    start_dir = File.join( File.dirname(__FILE__), '../..');
    @fscd = FileScanDir.new
    filter_dir = ['.svn', 'bin', 'obj']
    @fscd.add_dir_filter( filter_dir )
    @fscd.scan_dir(start_dir)
    @fscd.simulate = true
    deploy_dir = 'C:/'
    @fscd.copy_appl_to_dest(@fscd.result_list, 
                            start_dir, deploy_dir)