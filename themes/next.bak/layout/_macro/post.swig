{% macro render(post, is_index, post_extra_class) %}

  {% set headlessPost = Array.prototype.indexOf.call(['quote', 'picture'], post.type) > -1 %}
  {% set navlessPost = headlessPost %}

  <article class="post post-type-{{ post.type | default('normal') }} {{ post_extra_class | default('') }}" itemscope itemtype="http://schema.org/Article">

    {% if not headlessPost %}
      <header class="post-header">

        {# Not to show title for quote posts that do not have a title #}
        {% if not (is_index and post.type === 'quote' and not post.title) %}
          <h1 class="post-title" itemprop="name headline">
            {# Link posts #}
            {% if post.link %}
              <a class="post-title-link post-title-link-external" target="_blank" href="{{ url_for(post.link) }}" itemprop="url">
                {{ post.title or post.link }}
                <i class="fa fa-external-link-square"></i>
              </a>
            {% else %}
              {% if is_index %}
                <a class="post-title-link" href="{{ url_for(post.path) }}" itemprop="url">
                  {{ post.title | default(__('post.untitled'))}}
                </a>
              {% else %}
                {{ post.title }}
              {% endif %}
            {% endif %}
          </h1>
        {% endif %}

        <div class="post-meta">
          <span class="post-time">
            {{ __('post.posted') }}
            <time itemprop="dateCreated" datetime="{{ moment(post.date).format() }}" content="{{ date(post.date, config.date_format) }}">
              {{ date(post.date, config.date_format) }}
            </time>
          </span>

          {% if post.categories and post.categories.length %}
            <span class="post-category" >
              &nbsp; | &nbsp; {{ __('post.in') }}
              {% for cat in post.categories %}
                <span itemprop="about" itemscope itemtype="https://schema.org/Thing">
                  <a href="{{ url_for(cat.path) }}" itemprop="url" rel="index">
                    <span itemprop="name">{{ cat.name }}</span>
                  </a>
                </span>

                {% set cat_length = post.categories.length %}
                {% if cat_length > 1 and loop.index !== cat_length %}
                  {{ __('symbol.comma') }}
                {% endif %}

              {% endfor %}
            </span>
          {% endif %}

          {% if post.comments %}
            {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
              <span class="post-comments-count">
                &nbsp; | &nbsp;
                <a href="{{ url_for(post.path) }}#comments" itemprop="discussionUrl">
                  <span class="post-comments-count ds-thread-count" data-thread-key="{{ post.path }}" itemprop="commentsCount"></span>
                </a>
              </span>
            {% elseif theme.disqus_shortname %}
              <span class="post-comments-count">
              &nbsp; | &nbsp;
              <a href="{{ url_for(post.path) }}#comments" itemprop="discussionUrl">
                <span class="post-comments-count disqus-comment-count" data-disqus-identifier="{{ post.path }}" itemprop="commentsCount"></span>
              </a>
            </span>
            {% endif %}
          {% endif %}

          {% if not is_index and theme.facebook_sdk.enable and theme.facebook_sdk.like_button %}
            &nbsp; | &nbsp;
            <div class="fb-like" data-layout="button_count" data-share="true"></div>
          {% endif %}

        </div>
      </header>
    {% endif %}


    <div class="post-body">

      {# Gallery support #}
      {% if post.photos and post.photos.length %}
        <div class="post-gallery" itemscope itemtype="http://schema.org/ImageGallery">
          {% set COLUMN_NUMBER = 3 %}
          {% for photo in post.photos %}
            {% if loop.index0 % COLUMN_NUMBER === 0 %}<div class="post-gallery-row">{% endif %}
              <a class="post-gallery-img fancybox"
                 href="{{ url_for(photo) }}" rel="gallery_{{ post._id }}"
                 itemscope itemtype="http://schema.org/ImageObject" itemprop="url">
                <img src="{{ url_for(photo) }}" itemprop="contentUrl"/>
              </a>
            {% if loop.index0 % COLUMN_NUMBER === 2 %}</div>{% endif %}
          {% endfor %}

          {# Append end tag for `post-gallery-row` when (photos size mod COLUMN_NUMBER) is less than COLUMN_NUMBER #}
          {% if post.photos.length % COLUMN_NUMBER > 0 %}</div>{% endif %}
        </div>
      {% endif %}

      {% if is_index %}
        {% if post.description %}
          <span itemprop="description">{{ post.description }}</span>
          <div class="post-more-link text-center">
            <a class="btn" href="{{ url_for(post.path) }}">
              {{ __('post.read_more') }} &raquo;
            </a>
          </div>
        {% elif post.excerpt  %}
          {{ post.excerpt }}
          <div class="post-more-link text-center">
            <a class="btn" href="{{ url_for(post.path) }}{% if theme.scroll_to_more %}#more{% endif %}" rel="contents">
              {{ __('post.read_more') }} &raquo;
            </a>
          </div>
        {% elif theme.auto_excerpt.enable %}
          <span itemprop="articleBody">
            {% set content = post.content | striptags %}
            {{ content.substring(0, theme.auto_excerpt.length) }}
            {% if content.length > theme.auto_excerpt.length %}...{% endif %}
          </span>
          <div class="post-more-link text-center">
            <a class="btn" href="{{ url_for(post.path) }}{% if theme.scroll_to_more %}#more{% endif %}" rel="contents">
              {{ __('post.read_more') }} &raquo;
            </a>
          </div>
        {% else %}
          <span itemprop="articleBody">
            {% if post.type === 'picture' %}
              <a href="{{ url_for(post.path) }}">{{ post.content }}</a>
            {% else %}
              {{ post.content }}
            {% endif %}
          </span>
        {% endif %}
      {% else %}
        <span itemprop="articleBody">{{ post.content }}</span>
      {% endif  %}

      <div class="session-wechat" align="center">
        <img alt="关注微信公众号 haibintalk，最新文章主动推送" style="border-width:0" src="https://tp.linqmind.com/2016-12-07-qrcode_for_gh_ff0c28b2feaf_258.jpg"></img>
      </div>
      <div class="session-wechat-tip" align="center">
          关注微信公众号: haibintalk
      </div>


    </div>

    <footer class="post-footer">
      {% if post.tags and post.tags.length and not is_index %}
        <div class="post-tags">
          {% for tag in post.tags %}
            <a href="{{ url_for(tag.path) }}" rel="tag">#{{ tag.name }}</a>
          {% endfor %}
        </div>
      {% endif %}

      {% if not is_index and (post.prev or post.next) and not navlessPost %}
        <div class="post-nav">
          <div class="post-nav-next post-nav-item">
            {% if post.next %}
              <a href="{{ url_for(post.next.path) }}" rel="next" title="{{ post.next.title }}">
                <i class="fa fa-chevron-left"></i> {{ post.next.title }}
              </a>
            {% endif %}
          </div>

          <div class="post-nav-prev post-nav-item">
            {% if post.prev %}
              <a href="{{ url_for(post.prev.path) }}" rel="prev" title="{{ post.prev.title }}">
                {{post.prev.title}} <i class="fa fa-chevron-right"></i>
              </a>
            {% endif %}
          </div>
        </div>
      {% endif %}

      {% set isLast = loop.index % page.per_page === 0 %}
      {% if is_index and not isLast %}
        <div class="post-eof"></div>
      {% endif %}
    </footer>
  </article>

{% endmacro %}
