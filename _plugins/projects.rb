module Jekyll
    class ProjectPortfolioTag < Liquid::Tag
        def initialize(tag_name, text, tokens)
            super
            @project_name = text.split(" ").first
        end

        def render(context)
            site = context.registers[:site]
            page = find_project_page(site, @project_name)
            <<-EOS
            <li class="col4 item web">
                <img src="#{page.data['project_image']}" alt="" />
                <div class="col4 item-info">
                    <h3 class="title"><a href="/projects#{page.url}">#{page.data['title']}</a></h3>
                </div><!--END ITEM-INFO-->  
                <div class="item-info-overlay">
                <div>
                    <h4>#{page.data['project_tag']}</h4> 
                    <p>#{page.data['project_summary']}</p>
                    <a href="/projects#{page.url}" class="view">details</a>
                </div>                  
                </div><!--END ITEM-INFO-OVERLAY-->
            </li> 
            EOS
        end

        def find_project_page(site, name)
            site.pages.each do |page|
                return page if page.data['project_name'] == name
            end
            nil
        end
    end
end

Liquid::Template.register_tag('project_portfolio', Jekyll::ProjectPortfolioTag)