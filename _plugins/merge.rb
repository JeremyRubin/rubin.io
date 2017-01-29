module Jekyll
    module MergeFilter
        def merge(input, arg)
            input + arg
        end
    end
end

Liquid::Template.register_filter(Jekyll::MergeFilter)
