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
        open(url, request_options).read
      end
      json = JSON.parse(content);
    end

    private

    def request_options
      request_options = {}
      if ENV['GITHUB_AUTHORIZATION']
        request_options[:http_basic_authentication] = ENV['GITHUB_AUTHORIZATION'].split(':')
      end
      request_options
    end
  end

  module Url
    def self.repository(owner, repo)
      "https://api.github.com/repos/#{owner}/#{repo}"
    end
  end

  class FileCache
    def initialize
      @dir = File.join(Middleman::Application.root, ".cache", "github")
      FileUtils.mkdir_p(@dir)
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
          begin
            content = yield(f)
            f.write(content)
          rescue => e
            File.delete(path)
            throw e
          end

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
