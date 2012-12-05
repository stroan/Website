require 'nokogiri'

module Jekyll
    class HomePage < Page
        def initialize(site, base, dir)
            @site = site
            @base = base
            @dir = dir
            @name = "index.html"

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'home.html')

            categories = site.config['home_categories']
            category_posts = {}
            categories.each do |c|
                posts = (site.categories[c] or []).sort.reverse - category_posts.values
                category_posts[c] = posts.first unless posts.empty?
            end
            posts = category_posts.collect {|c,p| {"category" => c, "post" => p}}.sort{|l,r| r["post"].date.to_i <=> l["post"].date.to_i}

            self.data['title'] = "Home"
            self.data['posts'] = posts
        end
    end

    class HomePageGenerator < Generator
        safe true

        def generate(site)
            if site.layouts.key? 'home'
                site.pages << HomePage.new(site, site.source, "/")
            end
        end
    end
end