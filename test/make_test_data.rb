#!/usr/bin/env ruby

require "fileutils"

TEST_PATH = File.expand_path("..", __FILE__)
Dir.chdir(TEST_PATH)

def create_data_dir
  # test_data/data/
  # ├── emptydir/
  # ├── emptyfile
  # ├── testdir/
  # │   ├── a.txt
  # │   ├── b.txt
  # │   └── c.txt
  # └── testfile

  root_path = File.join("test_data", "data")

  # CREATE DIRECTORIES

  emptydir = File.join(root_path, "emptydir")
  testdir = File.join(root_path, "testdir")

  FileUtils.mkdir_p(emptydir)
  FileUtils.mkdir_p(testdir)

  # CREATE FILES

  emptyfile = File.join(root_path, "emptyfile")
  testfile = File.join(root_path, "testfile")

  a_file = File.join(testdir, "a.txt")
  b_file = File.join(testdir, "b.txt")
  c_file = File.join(testdir, "c.txt")

  FileUtils.touch(emptyfile)
  File.utime(1671306572, 1671306572, emptyfile)
  File.write(testfile, "test file\n")
  File.utime(1671306526, 1671306526, testfile)

  File.write(a_file, "a\n")
  File.utime(1671306647, 1671306647, a_file)
  File.write(b_file, "b\n")
  File.utime(1671306650, 1671306650, b_file)
  File.write(c_file, "c\n")
  File.utime(1671306654, 1671306654, c_file)
end

def create_conflicts_dir
  # test_data/data/
  # ├── emptydir/
  # ├── testdir
  # └── testfile/

  root_path = File.join("test_data", "conflicts", "data")

  # CREATE DIRECTORIES

  emptydir = File.join(root_path, "emptydir")
  testfile = File.join(root_path, "testfile")

  FileUtils.mkdir_p(emptydir)
  FileUtils.mkdir_p(testfile)

  # CREATE FILES

  testdir = File.join(root_path, "testdir")
  FileUtils.touch(testdir)
end

create_data_dir()
create_conflicts_dir()
FileUtils.touch(File.join("test_data", "TEST_DATA_CREATED"))
