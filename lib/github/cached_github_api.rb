require 'json'
require 'open-uri'

module GitHub

  class CachedGitHubApi

    def initialize
      @cache = FileCache.new
    end

    def repository(owner, repo)
      url = Url::repository(owner, repo)
      content = @cache.get_or_write(url) do |f|
        open(url).read
      end
      json = JSON.parse(content);
    end
  end

  module Url
    def self.repository(owner, repo)
      "https://api.github.com/repos/#{owner}/#{repo}"
    end
  end

  class FileCache
    def initialize
      @dir = Dir.mktmpdir("folioscope")
    end

    def get_or_write(key)
      path = File.join(@dir, normalize_key(key))

      begin
        File.open(path, "r") do |f|
          f.flock(File::LOCK_SH)
          return f.read
        end
      rescue => e
        File.open(path, File::RDWR | File::CREAT) do |f|
          f.flock(File::LOCK_EX)
          content = yield(f)
          f.write(content)

          return content
        end
      end
    end

    private

    def normalize_key(key)
      key.gsub('/', '__')
    end
  end
end
