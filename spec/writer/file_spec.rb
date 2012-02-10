require "spec_helper"

require "massive_sitemap/writer/file"

describe MassiveSitemap::Writer::File do
  let(:file_name) { 'test.txt' }
  let(:file_name2) { 'test-1.txt' }
  let(:writer) {  MassiveSitemap::Writer::File.new(file_name).tap { |w| w.init! } }

  after do
    FileUtils.rm(file_name) rescue nil
    FileUtils.rm(file_name2) rescue nil
  end

  it 'wrong template' do
    file_name = 'test'
     MassiveSitemap::Writer::File.new(file_name)
  end

  it 'create file' do
    writer.close!
    File.exists?(file_name).should be_true
  end

  it 'create second file on rotation' do
    writer.close!
    File.exists?(file_name).should be_true
    writer.init!
    writer.close!
    File.exists?(file_name2).should be_true
  end

  it 'write into file' do
    writer.print 'test'
    writer.close!
    `cat '#{file_name}'`.should == "test"
  end

  it 'write into second file' do
    writer.print 'test'
    writer.init!
    writer.print 'test2'
    writer.close!
    `cat '#{file_name2}'`.should == "test2"
  end
end