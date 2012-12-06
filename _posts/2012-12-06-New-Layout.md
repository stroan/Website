---
title: New Layout & Jekyll Plugins
layout: post
categories:
  - Tech
  - Everything
---

I put up this new version of the site the other day. There was a list of features I wanted my site to have, which the old blog was lacking. In particular I wanted a place for project pages, image gallery, archives, post categories, and a home page distinct from the blog. The previous version of the site used Jekyll, but only so far as using the features that come out of the box.

I was tossing up between moving WordPress, or writing Jekyll plugins to add the features I needed. I'm a big fan of Jekyll. There's almost no worrying about security patching, or sudden bursts of traffic taking down your databases, or whatnot. WordPress on the other hand would have given me the features I wanted out of the gate, at the cost of having to "manage" it. I ended up going with Jekyll again, and am pretty happy I did.

This site is a lot more of a real website than the last one, and I learned a good bit about the Jekyll plugin system and the various technologies it relies upon. Below are some interesting tidbits from making this new site.

### Parameterizable Liquid includes

I have an include file which contains the HTML for the header. This document includes the top menu, and I wanted to have the current section of the website be selected without having to have a custom version of the header for each part of the site.

The way I solved this was pretty simple, variables you assign in Liquid templates are visible in the included template. So the relevant section of the header template looks like:

{% highlight html %}
{% raw %}
<ul class="menu">
    <li><a href="/" {% if currentloc == "HOME" %} class="current" {% endif %}>Home</a></li>
    <li><a href="/gallery/" {% if currentloc == "GLRY" %} class="current" {% endif %}>Galleries</a></li>
    <li><a href="#" {% if currentloc == "PROJ" %} class="current" {% endif %}>Projects</a>
        <ul>
            <li><a href="/projects/haskell-libexpect.html">haskell-libexpect</a></li>
            <li><a href="/projects/lamn.html">lamn</a></li>
        </ul>
    </li>
    <li><a href="/blog/Everything/" {% if currentloc == "BLOG" %} class="current" {% endif %}>Blog</a></li>
    <li><a href="/about.html" {% if currentloc == "REME" %} class="current" {% endif %}>About Me</a></li>
</ul>
{% endraw %}
{% endhighlight %}

So each of the links in the top bar will get highlighted only if the Liquid variable `currentloc` is set to the right value. To set that value, right before including the header in each layout that uses it. So in the layout for the home page I have:

{% raw %}
    {% assign currentloc = "HOME" %}
    {% include header.html %}
{% endraw %}

So this is a very simple way of parameterizing your liquid includes. Just set global values before including them and reference those values in the include.

### Gallery generation with image embedding tag

The code for this plugin is [here](https://github.com/stroan/Website/blob/master/_plugins/galleries.rb) on Github, like the rest of the source of this site. I wanted to make the distinction between images that are part of the site structure, and site content. So I made a plugic that does two things. It generates a gallery page, passing it the list of galleries, along with the list of images in each gallery. It also exposes a Liquid tag `gallery_image` which takes two parameters, the first of which is the name of the gallery from which to take the image and the second is the name of the image in the gallery. The tag then includes the image and links to it.

The interesting thing here was accessing the site context in a Liquid tag. The Jekyll docs tell you how to do so in passing, but it's nice to see it done.

{% highlight ruby %}
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
{% endhighlight %}

Couldn't see a nicer way of writing the constructor. I may be misunderstanding Liquid here but it seems to give you a literal string of the content after the whitespace after the tag name up until the close brace. So I split the string on space and extract the parameters by hand.

The `load_gallery_def` method reads a description of the image galleries from a yml file in the project root. The `render` method on the tag returns the image. It makes it very straight forward to embed images, as well as have auto generated galleries, by just putting things like the following in blog posts:

{% raw %}
    {% gallery_image sketches wanda1 %}
{% endraw %}

The generation of the gallery itself is rather uninteresting, being quite similar to the example in the Jekyll docs [here](https://github.com/mojombo/jekyll/wiki/Plugins).

### Using page metadata in Liquid tags

The last plugin I'll describe here is used to fill in the project boxes on the home page. It was interesting to use extra metadata in the YAML front matter to fill in content related to that page elsewhere. The front matter for the libexpect project looks like:

{% highlight yaml %}
title: Haskell libexpect bindings
layout: project

project_name: hsexpect
project_image: /images/haskell-project.png
project_tag: Tech
project_summary: Haskell bindings to the C expect libraries for interacting with pseudoterminals.
{% endhighlight %}

The Liquid tag [here](https://github.com/stroan/Website/blob/master/_plugins/projects.rb) then uses that to produce the HTML for the boxes in the home page using tags like so:

{% highlight html %}
{% raw %}
<div class="portfolio-grid">
    <ul id="thumbs">
        {% project_portfolio hsexpect %}
        {% project_portfolio lamn %}
    </ul>
</div>
{% endraw %}
{% endhighlight %}

--------------

I hope some of these are of use to someone. Jekyll is a great content generation framework, if you take a little bit of time to get to know it.