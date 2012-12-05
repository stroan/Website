def load_gallery_def(base)
    YAML::load_file(File.join(base, "galleries.yml"))
end

module Jekyll
    class GalleryPage < Page
        def initialize(site, base, dir)
            @site = site
            @base = base
            @dir = dir
            @name = "index.html"

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'gallery.html')

            self.data['title'] = "Gallery"

            gallery_def = load_gallery_def(base)
            self.data['galleries'] = gallery_def.collect{|g, t| t['id'] = g ; t['images'] = t['images'].collect{|k,v| v.merge({"name" => k})} ; t }
        end
    end

    class GalleryPageGenerator < Generator
        safe true

        def generate(site)
            if site.layouts.key? 'home'
                site.pages << GalleryPage.new(site, site.source, "/gallery")
            end
        end
    end

    class GalleryImageTag < Liquid::Tag
        def initialize(tag_name, text, tokens)
            super
            args = text.split(" ")
            @gallery = args[0]
            @image = args[1]
        end

        def render(context)
            site = context.registers[:site]
            gallery_def = load_gallery_def(site.source)

            url = gallery_def[@gallery]["images"][@image]["url"]

            <<-EOS
<a href="#{url}"><img src="#{url}"/></a>
            EOS
        end
    end
end

Liquid::Template.register_tag('gallery_image', Jekyll::GalleryImageTag)