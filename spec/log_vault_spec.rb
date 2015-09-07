require 'spec_helper'
require 'timecop'
require 'log_vault'
require 'tempfile'

describe "LogVault" do

  before do
    new_time = Time.local(2015, 8, 20, 10, 10, 10)
    Timecop.freeze(new_time)
  end

  it "should return the default destination when it receives the destination() message before any format has been sepcified" do
    host = '127.0.0.1'
    var_hash = { 'host' => host }
    logvault = LogVault.new
    destination = logvault.destination(var_hash)
    expect(destination).to eq("/data/127.0.0.1/2015/08/20")
  end

  it "should return a file name starting with a SHA of a given file when it receives the #calculate_file_name" do
    # Set up test file
    testfile = Tempfile.new('logvault-test')
    testfile_name = 'log-test'
    testfile.write("woot\n")
    testfile.close()
    expected_file_name = "2620f3c4da2c31f0444a7f91b9d3d435c1d51af338783b8f6208e46b0085ea3a_#{testfile_name}"

    # Do we get the new filename we expect
    logvault = LogVault.new
    file_name = logvault.calculate_file_name(testfile.path, testfile_name)
    expect(file_name).to eq(expected_file_name)
  end

  it "should save a file to the logvault with the expected (sha-origname) when it receives #save" do
    testfile = Tempfile.new('logvault-test')
    testfile_name = 'log-file'
    testfile.write("woot\n")
    testfile.close()

    logvault = LogVault.new
    Dir.mktmpdir do |dir|
      logvault.destination_format_string = File.join(dir,"@host")
      logvault.save(testfile.path,testfile_name,"127.0.0.1")
      expect(File.exist?(
        File.join(dir,
                  "127.0.0.1",
                  "2620f3c4da2c31f0444a7f91b9d3d435c1d51af338783b8f6208e46b0085ea3a_#{testfile_name}")
      )).to be true
    end
  end
end
