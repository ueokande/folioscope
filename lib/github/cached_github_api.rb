require 'json'
require 'open-uri'

module GitHub

  class CachedGitHubApi

    def initialize(opts = {})
      @cache = FileCache.new
      @api = Api.new(
        :user => opts[:github_user],
        :token => opts[:github_token]
      )
    end

    def repository(owner, repo)
      key = cache_key(owner, repo)
      content = @cache.get_or_write(key) do
        content = @api.repository(owner, repo)
        JSON.dump(content)
      end
      json = JSON.parse(content);
    end

    def cache_user_repositories(user)
      repos = @api.user_repositories(user)
      repos.each do |repo|
        owner = repo['owner']['login']
        name = repo['name']
        key = cache_key(owner, name)
        @cache.safe_write(key) do
          JSON.dump(repo)
        end
      end
    end

    private

    def cache_key(owner, repo)
      "#{owner}_#{repo}"
    end
  end

  class Api
    def initialize(opts = {})
      @opts = opts
    end

    def repository(owner, repo)
      get("https://api.github.com/repos/#{owner}/#{repo}")
    end

    def user_repositories(owner)
      get("https://api.github.com/users/#{owner}/repos")
    end

    private

    def request_options
      opts = {}
      if @opts[:user] && @opts[:token]
        opts[:http_basic_authentication] = [@opts[:user], @opts[:token]]
      end
      opts
    end

    def get(uri)
      content = open(uri, request_options).read
      JSON.parse(content)
    end
  end

  class FileCache
    def initialize
      @dir = File.join(Middleman::Application.root, ".cache", "github")
      FileUtils.mkdir_p(@dir)
    end

    def get_or_write(key)
      path = File.join(@dir, key)

      begin
        File.open(path, "r") do |f|
          f.flock(File::LOCK_SH)
          return f.read
        end
      rescue => e
        File.open(path, File::RDWR | File::CREAT) do |f|
          f.flock(File::LOCK_EX)
          begin
            content = yield
            f.write(content)
          rescue => e
            File.delete(path)
            throw e
          end

          content
        end
      end
    end

    def safe_write(key)
      path = File.join(@dir, key)
      File.open(path, File::RDWR | File::CREAT) do |f|
        f.flock(File::LOCK_EX)
        begin
          f.write(yield)
        rescue => e
          File.delete(path)
          throw e
        end
      end
    end
  end
end
