stubbed_mtime = 1
AfterStep do
  # to prevent rails caching by mtime, which is only precise to the second
  File.stub(:mtime) { Time.at(stubbed_mtime += 1) }
end
