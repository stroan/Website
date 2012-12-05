module Jekyll
    module DateFilters
        def date_to_short_month(input)
            input.strftime("%^b")
        end

        def date_to_day(input)
            input.day
        end

        def date_to_year(input)
            input.year
        end
    end
end

Liquid::Template.register_filter(Jekyll::DateFilters)