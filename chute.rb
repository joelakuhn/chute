#!/usr/bin/env ruby

require 'open3'

class ChuteEntity
  attr_accessor :path
  attr_accessor :contents

  def initialize(path, contents)
    @path = path
    @contents = contents
  end
end

class Chute
  attr_accessor :files
  attr_accessor :wd

  def initialize(files)
    @files = files
    @wd = [ ]
  end

  def self.glob(glob)
    paths = Dir.glob(glob);
    Chute.new(paths.map{|p| ChuteEntity.new(p, File.open(p).read)})
  end

  def self.file(path)
    Chute.new([ ChuteEntity.new(path, File.open(path).read) ]);
  end

  def merge(*entity_sets)
    entity_sets.each do |c|
      c.files.each do |f|
        @files.push(f)
      end
    end
    self
  end

  def concat(path = nil)
    @files = [ ChuteEntity.new( path, @files.map{|f| f.contents}.join("\n"),) ]
    self
  end

  def replace(from, to)
    @files.each do |f|
      f.contents = f.contents.gsub(from, to)
    end
    self
  end

  def do()
    @files.each do |f|
      yield f
    end
    self
  end

  def extension(ext)
    if ext[0] != '.'
      ext = ".#{ext}"
    end

    @files.each do |f|
      f.path = File.basename(f.path, '.*') + ext
    end
    self
  end

  def save()
    @files.each do |f|
      unless f.path.nil?
        fh = File.open(f.path, 'w')
        fh.write(f.contents)
        fh.close
      end
    end
    self
  end

  def save_as(path)
    fh = File.open(path, 'w');
    @files.each do |f|
      fh.write(f.contents)
    end
    fh.close
    self
  end

  def cd(path)
    if path == '-'
      Dir::chdir(@wd.pop())
    else
      @wd.push(Dir::pwd)
      Dir.chdir(path)
    end
    self
  end

  def pipe(command, *args)
    @files.each do |f|
      f.contents = pipe_to_command(command, f.contents);
    end
    self
  end

  def pipe_to_command(command, input, *args)
    result = nil
    begin
      Open3.popen3(command, *args) do |stdin, stdout, stderr, thread|
        stdin.write(input)
        stdin.close()
        result = stdout.read()
        thread.value
      end
    rescue Errno::ENOENT
      puts "Could not execute: #{command}";
      exit
    end

    return result
  end

end

specfile = './chutespec.rb'

if ARGV.length == 1
  specfile = ARGV[0]
end

if File.exists? specfile
  require specfile
end
