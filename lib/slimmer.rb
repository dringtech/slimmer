require 'nokogiri'

module Slimmer

  class App
    
    def initialize(app,options = {})
      @app = app
      @skin = Skin.new(options[:template_host])
    end

    def call(env)
      status,env,body = @app.call(env)
      rewrite_response([status,env,body])
    end

    def on_success(request,body)
      @skin.success(request, body)
    end

    def on_error(request,status, body)
      @skin.error(request, '500')
    end

    def on_404(request,body)
      @skin.error(request, '404')
    end

    def s(body)
      return body.to_s unless body.respond_to?(:each)
      b = ""
      body.each {|a| b << a }
      b
    end

    def rewrite_response(triplet)
      status, headers, app_body = triplet
      request = Rack::Request.new(headers)
      case status.to_i
      when 200
        if headers['Content-Type'] =~ /text\/html/
          rewritten_body = on_success(request,s(app_body))
        else
          rewritten_body = app_body
        end
      when 301, 302
        rewritten_body = ""
        redirect_uri = URI.parse(headers['location'])
        if redirect_uri.host =~ /alphagov\.co\.uk/
          redirect_uri.host = source_request.host
          redirect_uri.port = source_request.port
        end
        headers['location'] = redirect_uri.to_s
      when 304
        rewritten_body = app_body
      when 404
        rewritten_body = on_404(request,s(app_body))
      else
        rewritten_body = on_error(request,status, s(app_body))
      end
      [status, filter_headers(headers), rewritten_body]
    end

    def filter_headers(header_hash)
      valid_keys = ['vary', 'set-cookie', 'location', 'content-type']
      header_hash.keys.each do |key|
        header_hash.delete(key) unless valid_keys.include?(key.downcase)
      end
      header_hash
    end
  end

  class UrlRewriter
    
    def initialize(request)
      @request = request
    end

    def filter(src,dest)
      rewrite_document src 
    end

    def rewrite_document(doc)
      rewrite_nodes doc.css('body img'),'src' 
      rewrite_nodes doc.css('script'),'src' 
      rewrite_nodes doc.css('link'),'href' 
    end

    def rewrite_nodes(nodes,attr)
      nodes.each do |node|
        next unless node.attr(attr)
        node_uri = URI.parse(node.attr(attr))
        node.attribute(attr).value = rewrite_url(node_uri).to_s
      end
    end

    def rewrite_url(uri)
      unless uri.absolute?
        uri.scheme = @request.scheme
        if @request.host =~ /:/
          host,port = @request.host.split(":")
          uri.host = host
          uri.port = port
        else
          uri.host =   @request.host
          uri.port =   @request.port
        end
      end   
      uri
    end

  end

  class TitleInserter
    def filter(src,dest)
      title = src.at_css('head title')
      head  = dest.at_xpath('/html/head')
      if head && title
        insert_title(title,head)
      end
    end
    
    def insert_title(title, head)
      if head.at_css('title').nil? 
        head.first_element_child.nil? ? head << title : head.first_element_child.before(title)
      else
        head.at_css('title').replace(title)
      end
    end
  end

  class TagMover
    def filter(src,dest)
      move_tags(src, dest, 'script','src')
      move_tags(src, dest, 'link',  'href')
    end

    def move_tags(src,dest,type,comp)
      already_there = dest.css(type).map { |node| 
        node.has_attribute?(comp) ? node.attr(comp) : nil
      }.compact
      src.css(type).each do |node|
        if node.has_attribute?(comp) && ! already_there.include?(node.attr(comp))
          node.remove
          dest.at_xpath('/html/head') << node
        end
      end
    end
  end

  class BodyInserter
    def filter(src,dest)
      body = src.fragment(src.at_css('article')) 
      dest.at_css('article').replace(body)
    end
  end

  class Skin

    def initialize(asset_host)
      @asset_host = asset_host
    end

    def load_template(template)
      open("#{@asset_host}/#{template}.html").read
    end

    def template(template)
      if ENV["RACK_ENV"] == 'development'
        load_template(template)
      else
        @template_cache ||= Hash.new {|hash,key|
            hash[key] = self.load_template(key)
        }
        @template_cache[template]
      end
    end

    def error(request,template)
      processors = [
        TitleInserter.new()
      ]
      self.process(processors,"<html></html>",template(template))
    end

    def process(processors,body,template)
      src = Nokogiri::HTML.parse(body.to_s)
      dest = Nokogiri::HTML.parse(template)

      processors.each do |p|
        p.filter(src,dest)
      end
      
      return dest.to_html
    end

    def success(request,body)
      
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        BodyInserter.new()
      ]

      if ENV["RACK_ENV"] == 'development'
        processors.unshift UrlRewriter.new(request)
      end
      
      self.process(processors,body,template('wrapper'))
    end
  end


end
