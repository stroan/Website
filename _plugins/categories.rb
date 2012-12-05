def archive_key_to_address(key)
    archive_key_to_date(key).strftime("%Y-%b.html")
end

def archive_key_to_date(key)
    Time.utc(key[:year], key[:month], 1)
end

def months_to_month_count(months)
    months.collect do |key, pages|
        {'name' => archive_key_to_date(key).strftime("%B %Y"),
         'address' => archive_key_to_address(key),
         'count' => pages.length}
    end
end

module Jekyll

    class CategoryPage < Page
        def initialize(site, base, dir, category, pagination, page_index, months)
            @site = site
            @base = base
            @dir = dir
            @name = page_index == 1 ? 'index.html' : "page#{page_index}.html"

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
            self.data['category'] = category
            self.data['title'] = category
            self.data['posts'] = pagination[page_index - 1]

            self.data['paginated'] = true
            self.data['newest_page_index'] = 1
            self.data['oldest_page_index'] = pagination.length
            self.data['page_index'] = page_index
            self.data['page_count'] = pagination.length
            self.data['newer_page_index'] = page_index > 1 ? page_index - 1 : 1
            self.data['older_page_index'] = page_index < pagination.length ? page_index + 1 : pagination.length
            self.data['newer_page_address'] = page_index > 2 ? "page#{page_index - 1}.html" : 'index.html'
            self.data['older_page_address'] = pagination.length == 1 ? 'index.html' : 
                (page_index < pagination.length ? "page#{page_index + 1}.html" : "page#{page_index}.html")
            self.data['newest_page_address'] = 'index.html'
            self.data['oldest_page_address'] = pagination.length == 1 ? 'index.html' : "page#{pagination.length}.html"

            self.data['archives'] = true
            self.data['archive'] = months_to_month_count(months)
        end
    end

    class ArchivePage < Page
        def initialize(site, base, dir, category, month, months)
            @site = site
            @base = base
            @dir = dir
            @name = archive_key_to_address(month)

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
            self.data['category'] = category
            self.data['title'] = "#{category} - #{archive_key_to_date(month).strftime('%^b %y')}"
            self.data['posts'] = months[month].reverse

            self.data['paginated'] = false

            self.data['archives'] = true
            self.data['archive'] = months_to_month_count(months)
        end
    end

    class CategoryPageGenerator < Generator
        safe true

        def generate(site)
            if site.layouts.key? 'category_index'
                dir = site.config['category_dir'] || 'categories'

                site.categories.each do |category, pages|
                    months = {}
                    pages.sort.each do |page|
                        key = {:year => page.date.year,
                               :month => page.date.month}
                        months[key] = months[key] || []
                        months[key] << page
                    end

                    months.each do |month, pages|
                        site.pages << ArchivePage.new(site, site.source, File.join(dir, category), category, month, months)
                    end

                    pagination = pages.sort.reverse.each_slice(site.config['paginate']).to_a
                    pagination.length.times do |page_index|
                        site.pages << CategoryPage.new(site, site.source, File.join(dir, category), category, pagination, page_index + 1, months)
                    end
                end
            end
        end
    end

end