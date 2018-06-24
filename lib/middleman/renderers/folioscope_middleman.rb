require 'redcarpet'
require 'middleman-core/renderers/redcarpet'
require 'active_support/core_ext/module/attribute_accessors'
require 'lib/github/cached_github_api'

module Middleman
  module Renderers
    module  FolioscopeMiddlemanRedcarpetHTML
      EXTENDED_TAG_REGEX = /!\[([^\]]*)\]\[([^\]]*)\]/
      raise "environment variable 'GITHUB_USER' is not set" unless ENV['GITHUB_USER']
      GITHUB = GitHub::CachedGitHubApi.new({
        :github_user => ENV['GITHUB_USER'],
        :github_token => ENV['GITHUB_TOKEN']
      })
      GITHUB.cache_user_repositories(ENV['GITHUB_USER'])

      def preprocess(full_document)
        full_document.gsub(EXTENDED_TAG_REGEX) do |match|
          name, link = EXTENDED_TAG_REGEX.match(match).captures
          case name
          when 'github'
            render_github_link(link)
          else
            match
          end
        end
      end

      private

      def render_github_link(link)
        link = URI.parse(link).path.sub(/\A\//, '')
        owner, repo = link.split('/')
        if !owner || !repo
          warn "User and/or repository is blank in GitHub link: #{link}"
          return link;
        end

        repo = GITHUB.repository(owner, repo)

        href = repo["html_url"]
        avatar_url = repo["owner"]["avatar_url"]
        description = repo["description"]


        %(<a href="#{href}" class="external-link-github">
            <img class="external-link-github-avatar" src="#{avatar_url}" />
            <span class="external-link-github-title">#{link}</span>
            <span class="external-link-github-description">#{description}</span>
            <span class="external-link-github-service">github.com</span>
          </a>)
      end
    end

    MiddlemanRedcarpetHTML.send :include, FolioscopeMiddlemanRedcarpetHTML
  end
end
