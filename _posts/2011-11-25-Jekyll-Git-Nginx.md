---
title: Jekyll, Git, and Nginx
layout: post
categories:
  - Tech
  - Everything
---

The What
--------

I've half-written too many CMSes in attempts to create a website in a manner that didn't infuriate me the way so many of the existing solutions do. I have no need for widget systems, user selectable themes, or other such features. I want to separate content from presentation, and little more.

Github Pages introduced me to [Jekyll](https://github.com/mojombo/jekyll), a ruby library that compiles templates and content to static files which can then be served by any web server. To update your website on Github Pages all you need to do is edit your files on your local machine, commit them with git, and push them to Github. Github then compiles the new version of your website and serves it. This is exactly what I want to be able to do on my own domain. 

A large element of my attraction towards Jekyll is that all my templates and all my content are stored as plain text in a git repository. I can repurpose any part of what I write. If I wish to move to another platform I can do so easilly. By virtue of being plaintext, the files can be manipulated with all the tools available that work with plaintext files. I am not bound to whatever WYSIWYG editor the CMS deigns to provide. Also, running the system myself, on my own server, gives me access to the Jekyll plugin system as well as letting me play with extending the core gem itself, if I feel the urge. 

The other two parts of the system didn't require much contemplation. Git fits the bill perfectly here, providing version control, and a secure deployment mechanism. Nginx is a powerful web server with a beautiful configuration file format. With these three components properly configured, I have exactly the feature set I wanted.

The How
-------

There are plenty of docs on getting started with building Jekyll sites:

* [Installing Jekyll](https://github.com/mojombo/jekyll/wiki/Install)
* [Using Jekyll](https://github.com/mojombo/jekyll/wiki/Usage)
* [Source](https://github.com/stroan/Website) for this site.
* [Other sites](https://github.com/mojombo/jekyll/wiki/Sites)

Deploying and automatically rebuilding with git is a straight forward process. Git provides hooks, which are scripts that it will call when certain actions are performed. One of those hooks is the post-receive hook. It fires after code has been pushed into the repository.

The first thing to do is to make a [bare git repo](http://book.git-scm.com/4_setting_up_a_public_repository.html) on my web server that I will push my code into. I also check it out into a second folder, because a bare repo is quite different to a regular repo.

{% highlight bash %}
mkdir ~/Website
cd ~/Website
git init --bare
git clone ~/Website ~/WebsiteClone
{% endhighlight %}

The post recieve hook lives in ~/Website/hooks/post-receive, and needs to be executable. The hook will update the clone of the public repository, and run jekyll against the newly checked out code. My post-receive script looks like: 

{% highlight bash %}
#!/bin/bash

# Update the checkout
cd ~/WebsiteClone/
unset GIT_DIR
git pull origin master

# Run Jekyll.
source ~/.bash_profile
rvm use ruby-1.9.3
jekyll --no-auto --no-server

exec git-update-server-info
{% endhighlight %}

Now I can add my web server as a git remote to my local checkout of my jekyll website, to allow me to easilly push to my web server.

    git remote add live user@stroantree.net:Website

With all this git configuration in place I can push my local code to my webserver, and have jekyll rebuild my website automatically. The last step is also straight forward, configuring nginx, my web server of choice, to serve the site. The configuration for this site is quite simply:

    server {
            listen 80;
            server_name www.stroantree.net stroantree.net;
    
            access_log  /var/log/nginx/stroantree.net.access.log;

            location / {
                    index index.htm index.html;
                    root /home/user/WebsiteClone/_site/;
            }
    }

So now when I want to deploy new content to my site, I edit my files, commit my changes and push directly to my web server.

    $ vim _posts/2011-11-25-This_Post.md
    $ git commit -am "New post!"
    $ git push live master

Bliss.
