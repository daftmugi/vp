#!/usr/bin/env -S ruby -w

load File.expand_path("../../bin/vp", __FILE__)
TEST_PATH = File.expand_path("..", __FILE__)
Dir.chdir(TEST_PATH)

unless File.file?(File.join("test_data", "TEST_DATA_CREATED"))
  abort("Missing some test data.\nRun make_test_data.rb at least once.")
end

require "minitest/autorun"

class VPTest < Minitest::Test
  def test_no_vp_file
    vp = VP.new
    error = assert_raises(RuntimeError) { vp.list_vp() }
    assert_equal("No VP file given", error.message)
  end

  def test_list_very_verbose
    vp = VP.new(vp_path: "test_data/testvp.vp", very_verbose: true)

    expected = <<~EOS
    Archive: test_data/testvp.vp
       Size       Offset       Date       Time    Path
    ----------  ----------  ----------  --------  -----------------------------------
                        16                        data/
                        16                        data/emptydir/
                        16                        data/testdir/
             2          16  2022-12-17  13:50:47  data/testdir/a.txt
             2          18  2022-12-17  13:50:50  data/testdir/b.txt
             2          20  2022-12-17  13:50:54  data/testdir/c.txt
            10          22  2022-12-17  13:48:46  data/testfile
    ----------                                    -----------------------------------
            16                                    7 files
    EOS

    assert_output(expected, "") { vp.list_vp() }
  end

  def test_extract
    vp = VP.new(vp_path: "test_data/testvp.vp", root_path: "test_data/outdir", noop: true)

    expected = <<-EOS
    create    data/
    create    data/emptydir/
    create    data/testdir/
   extract    data/testdir/a.txt
   extract    data/testdir/b.txt
   extract    data/testdir/c.txt
   extract    data/testfile
    EOS

    assert_output(expected, "") { vp.extract_vp() }
  end

  def test_pipe_extract_single_file
    vp = VP.new(vp_path: "test_data/testvp.vp", regex: /testfile/)

    expected = <<~EOS
    test file
    EOS

    assert_output(expected, "") { vp.pipe_extract_vp() }
  end

  def test_pipe_extract_multiple_files
    vp = VP.new(vp_path: "test_data/testvp.vp", regex: /\.txt$/)

    expected = <<~EOS
    a
    b
    c
    EOS

    assert_output(expected, "") { vp.pipe_extract_vp() }
  end

  def test_create_very_verbose
    vp = VP.new(vp_path: "testout.vp", root_path: "test_data/data", noop: true, very_verbose: true)

    expected = <<~EOS
     Action      Size       Offset       Date       Time    Path
    --------  ----------  ----------  ----------  --------  -----------------------------------
    archive                       16                        data/
    archive                       16                        data/emptydir/
    skip               0           0  2022-12-17  13:49:32  data/emptyfile
    archive                       16                        data/testdir/
    archive            2          16  2022-12-17  13:50:47  data/testdir/a.txt
    archive            2          18  2022-12-17  13:50:50  data/testdir/b.txt
    archive            2          20  2022-12-17  13:50:54  data/testdir/c.txt
    archive           10          22  2022-12-17  13:48:46  data/testfile
    --------  ----------  ----------  ----------  --------  -----------------------------------
                      16                                    7 files
    EOS

    assert_output(expected, "") { vp.create_vp() }
  end

  def test_data_file_list
    vp = VP.new(vp_path: "testout.vp", root_path: "test_data/data", noop: true)

    dirname = File.dirname(vp.options[:root_path])
    Dir.chdir(dirname) do
      file_list = vp.data_file_list()
      file_list_names = file_list.map { |f| [f.name, f.path] }

      expected = [
        ["data",      "data"],
        ["emptydir",  "data/emptydir"],
        ["..",        "data/emptydir/.."],
        ["emptyfile", "data/emptyfile"],
        ["testdir",   "data/testdir"],
        ["a.txt",     "data/testdir/a.txt"],
        ["b.txt",     "data/testdir/b.txt"],
        ["c.txt",     "data/testdir/c.txt"],
        ["..",        "data/testdir/.."],
        ["testfile",  "data/testfile"],
        ["..",        "data/.."],
      ]

      assert_equal(expected, file_list_names)
    end
  end

  def test_file_directory_mismatch_on_disk
    vp = VP.new(vp_path: "test_data/testvp.vp", root_path: "test_data/conflicts", noop: true)

    expected = <<-EOS
      skip    data/
      skip    data/emptydir/
     error    test_data/conflicts/data/testdir exists but is not a directory
              -> skipping data/testdir/
     error    test_data/conflicts/data/testdir exists but is not a directory
              -> skipping data/testdir/a.txt
     error    test_data/conflicts/data/testdir exists but is not a directory
              -> skipping data/testdir/b.txt
     error    test_data/conflicts/data/testdir exists but is not a directory
              -> skipping data/testdir/c.txt
     error    test_data/conflicts/data/testfile/ exists but is not a file
              -> skipping data/testfile
    EOS

    assert_output(expected, "") { vp.extract_vp() }
  end

  def test_find_duplicates
    vp = VP.new

    expected = <<~EOS
    [override]   vp0.vp :: data/a.txt :: vp1.vp
    [override]   vp1.vp :: data/b.txt :: vp2.vp
    [override]   vp2.vp :: data/c.txt :: vp3.vp
    EOS

    Dir.chdir("test_data/dups") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_given_exclude
    vp = VP.new(exclude_vps: ["vp1.vp", "vp2.vp"])

    expected = <<~EOS
    [override]   vp0.vp :: data/a.txt :: vp1.vp
    [override]   vp2.vp :: data/c.txt :: vp3.vp
    EOS

    Dir.chdir("test_data/dups") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_with_one_path_and_given_exclude
    vp = VP.new(paths: ["dups"], exclude_vps: ["dups/vp1.vp", "dups/vp2.vp"])

    expected = <<~EOS
    [override]   dups/vp0.vp :: data/a.txt :: dups/vp1.vp
    [override]   dups/vp2.vp :: data/c.txt :: dups/vp3.vp
    EOS

    Dir.chdir("test_data") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_with_multiple_paths
    vp = VP.new(paths: ["mod1", "mod2", "mod3", "mod4"])

    expected = <<~EOS
    [override]   mod1/vp1.vp :: data/a.txt :: mod2/vp2.vp, mod4/vp4.vp
    [override]   mod1/vp1.vp :: data/b.txt :: mod2/vp2.vp
    [override]   mod1/vp1.vp :: data/maps/c.dds :: mod2/vp2.vp, mod3/vp3.vp, mod4/vp4.vp
    [override]   mod1/vp1.vp :: data/maps/one.dds :: mod2/vp2.vp
    [shadow]     mod1/vp1.vp :: data/maps/one.dds <> data/maps/other/one.dds :: mod3/vp3.vp
    [shadow]     mod1/vp1.vp :: data/maps/one.dds <> data/maps/test/one.dds :: mod4/vp4.vp
    [shadow]     mod1/vp1.vp :: data/maps/other/two.dds <> data/maps/two.dds :: mod3/vp3.vp
    [shadow]     mod1/vp1.vp :: data/maps/other/two.dds <> data/maps/test/two.dds :: mod4/vp4.vp
    [shadow]     mod4/vp4.vp :: data/effects/abc.dds <> data/effects/other/abc.dds :: mod4/vp4.vp
    EOS

    Dir.chdir("test_data/dups_multi") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_multiple_paths_and_given_exclude
    vp = VP.new(paths: ["mod1", "mod2", "mod3", "mod4"], exclude_vps: ["mod1/vp1.vp", "mod2/vp2.vp"])

    expected = <<~EOS
    [override]   mod1/vp1.vp :: data/a.txt :: mod2/vp2.vp, mod4/vp4.vp
    [override]   mod1/vp1.vp :: data/maps/c.dds :: mod2/vp2.vp, mod3/vp3.vp, mod4/vp4.vp
    [override]   mod1/vp1.vp :: data/maps/one.dds :: mod2/vp2.vp
    [shadow]     mod1/vp1.vp :: data/maps/one.dds <> data/maps/other/one.dds :: mod3/vp3.vp
    [shadow]     mod1/vp1.vp :: data/maps/one.dds <> data/maps/test/one.dds :: mod4/vp4.vp
    [shadow]     mod1/vp1.vp :: data/maps/other/two.dds <> data/maps/two.dds :: mod3/vp3.vp
    [shadow]     mod1/vp1.vp :: data/maps/other/two.dds <> data/maps/test/two.dds :: mod4/vp4.vp
    [shadow]     mod4/vp4.vp :: data/effects/abc.dds <> data/effects/other/abc.dds :: mod4/vp4.vp
    EOS

    Dir.chdir("test_data/dups_multi") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_regex
    vp = VP.new(paths: ["mod1", "mod2", "mod3", "mod4"], regex: /\.txt$/)

    expected = <<~EOS
    [override]   mod1/vp1.vp :: data/a.txt :: mod2/vp2.vp, mod4/vp4.vp
    [override]   mod1/vp1.vp :: data/b.txt :: mod2/vp2.vp
    EOS

    Dir.chdir("test_data/dups_multi") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_regex_path_type
    vp = VP.new(paths: ["mod1", "mod2", "mod3", "mod4"], regex: Regexp.new("data/maps"))

    expected = <<~EOS
    [override]   mod1/vp1.vp :: data/maps/c.dds :: mod2/vp2.vp, mod3/vp3.vp, mod4/vp4.vp
    [override]   mod1/vp1.vp :: data/maps/one.dds :: mod2/vp2.vp
    [shadow]     mod1/vp1.vp :: data/maps/one.dds <> data/maps/other/one.dds :: mod3/vp3.vp
    [shadow]     mod1/vp1.vp :: data/maps/one.dds <> data/maps/test/one.dds :: mod4/vp4.vp
    [shadow]     mod1/vp1.vp :: data/maps/other/two.dds <> data/maps/two.dds :: mod3/vp3.vp
    [shadow]     mod1/vp1.vp :: data/maps/other/two.dds <> data/maps/test/two.dds :: mod4/vp4.vp
    EOS

    Dir.chdir("test_data/dups_multi") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end

  def test_find_duplicates_checksum
    vp = VP.new(paths: ["mod1", "mod2", "mod3", "mod4"], checksum_duplicates: true)

    expected = <<~EOS
    [identical]  data/a.txt :: mod1/vp1.vp, mod4/vp4.vp
    [identical]  data/b.txt :: mod1/vp1.vp, mod2/vp2.vp
    [identical]  data/maps/c.dds :: mod1/vp1.vp, mod2/vp2.vp, mod3/vp3.vp, mod4/vp4.vp
    [identical]  data/maps/one.dds :: mod1/vp1.vp, mod2/vp2.vp
    [identical]  data/maps/other/one.dds :: mod3/vp3.vp, mod4/vp4.vp:data/maps/test/one.dds
    [identical]  data/maps/other/two.dds :: mod1/vp1.vp, mod3/vp3.vp:data/maps/two.dds, mod4/vp4.vp:data/maps/test/two.dds
    EOS

    Dir.chdir("test_data/dups_multi") do
      assert_output(expected, "") { vp.find_duplicates() }
    end
  end
end
