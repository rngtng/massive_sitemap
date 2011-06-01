require 'bundler/gem_tasks'

require 'rdoc/task'
RDoc::Task.new do |rd|
  rd.main = "README.rdoc"
  rd.title = 'big_sitemap'
  rd.options << '--line-numbers' << '--inline-source'
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test' << Rake.original_dir
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
