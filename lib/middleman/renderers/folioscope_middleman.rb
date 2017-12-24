require 'redcarpet'
require 'middleman-core/renderers/redcarpet'
require 'active_support/core_ext/module/attribute_accessors'

module Middleman
  module Renderers
    module  FolioscopeMiddlemanRedcarpetHTML
      EXTENDED_TAG_REGEX = /!\[([^\]]*)\]\[([^\]]*)\]/

      def initialize(options={})
        super
      end

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

        href = "https://github.com/#{link}"
        avatar_url = 'https://avatars1.githubusercontent.com/u/534166?v=4'
        description = 'This ia github link.'

        %(<a href="#{href}" class="markdown-extended-github">
            <img src="#{avatar_url}" />
            <p class="markdown-extended-github-title">#{link}</p>
            <p class="markdown-extended-github-description">#{description}</p>
          </a>)
      end
    end

    MiddlemanRedcarpetHTML.send :include, FolioscopeMiddlemanRedcarpetHTML
  end
end
