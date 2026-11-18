# frozen_string_literal: true

module SeoHelper
  def meta_title(page_title = nil)
    title = page_title.presence || content_for(:title).presence

    if title.blank?
      "ARC Duka – African Ruby Community Shop | Official Merchandise"
    elsif title == "ARC Duka" || title.include?("ARC Duka – African Ruby Community Shop")
      title
    elsif title.include?("ARC Duka")
      title
    else
      "#{title} | ARC Duka – African Ruby Community Shop"
    end
  end

  def meta_description(custom_description = nil)
    desc = custom_description.presence || content_for(:meta_description).presence
    desc.presence || "Official merchandise store for the African Ruby Community (ARC). Shop high-quality t-shirts, hoodies, mugs, stickers, and developer gear crafted for the African tech ecosystem."
  end

  def meta_keywords(custom_keywords = nil)
    kw = custom_keywords.presence || content_for(:meta_keywords).presence
    kw.presence || "African Ruby Community, ARC Duka, Ruby merchandise, tech swag Africa, developer clothing, Ruby on Rails Kenya, African developers, tech apparel, Nairobi Ruby"
  end

  def meta_robots
    content_for(:robots).presence || "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1"
  end

  def canonical_url
    if content_for?(:canonical_url)
      content_for(:canonical_url)
    else
      "#{request.base_url}#{request.path}"
    end
  end

  def seo_meta_tags
    tags = [
      tag.meta(name: "description", content: meta_description),
      tag.meta(name: "keywords", content: meta_keywords),
      tag.meta(name: "author", content: "African Ruby Community"),
      tag.meta(name: "robots", content: meta_robots),
      tag.link(rel: "canonical", href: canonical_url),
      tag.meta(name: "theme-color", content: "#dc2626"),
      tag.meta(name: "msapplication-TileColor", content: "#dc2626")
    ]

    if ENV["GOOGLE_SITE_VERIFICATION"].present?
      tags << tag.meta(name: "google-site-verification", content: ENV["GOOGLE_SITE_VERIFICATION"])
    end

    if ENV["BING_SITE_VERIFICATION"].present?
      tags << tag.meta(name: "msvalidate.01", content: ENV["BING_SITE_VERIFICATION"])
    end

    safe_join(tags)
  end

  def json_ld_tag(data)
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def organization_json_ld
    {
      "@context": "https://schema.org",
      "@type": "OnlineStore",
      "@id": "#{request.base_url}/#organization",
      "name": "ARC Duka",
      "alternateName": "African Ruby Community Duka",
      "url": request.base_url,
      "logo": asset_url("arc_logo_coloured.png"),
      "description": "Official merchandise store for the African Ruby Community (ARC). Celebrating African excellence in Ruby development through quality merchandise.",
      "sameAs": [
        "https://x.com/ruby_african",
        "https://www.instagram.com/africanruby_community",
        "https://www.linkedin.com/company/african-ruby-community",
        "https://www.youtube.com/@nairubyorg7626",
        "https://github.com/nairuby",
        "https://rubycommunity.africa",
        "https://rubyconf.africa"
      ],
      "contactPoint": {
        "@type": "ContactPoint",
        "contactType": "customer service",
        "email": "info@rubycommunity.africa",
        "availableLanguage": [ "English", "Swahili" ]
      }
    }
  end

  def website_json_ld
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "@id": "#{request.base_url}/#website",
      "url": request.base_url,
      "name": "ARC Duka",
      "description": "African Ruby Community Shop",
      "publisher": { "@id": "#{request.base_url}/#organization" },
      "potentialAction": {
        "@type": "SearchAction",
        "target": {
          "@type": "EntryPoint",
          "urlTemplate": "#{request.base_url}/products?q={search_term_string}"
        },
        "query-input": "required name=search_term_string"
      }
    }
  end

  def breadcrumb_json_ld(items)
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items.compact.map.with_index(1) do |item, idx|
        {
          "@type": "ListItem",
          "position": idx,
          "name": item[:name],
          "item": item[:url]
        }
      end
    }
  end

  def product_json_ld(product)
    image = product.image_url.presence || asset_url("arc_logo_coloured.png")
    currency = product.currency.presence || "KES"

    data = {
      "@context": "https://schema.org",
      "@type": "Product",
      "name": product.name,
      "image": [ image ],
      "description": product.description.presence || "#{product.name} — official African Ruby Community merchandise.",
      "sku": product.id.to_s,
      "brand": {
        "@type": "Brand",
        "name": "African Ruby Community"
      },
      "category": product.category.presence || "Apparel",
      "offers": {
        "@type": "Offer",
        "url": product_url(product),
        "priceCurrency": currency,
        "price": sprintf("%.2f", product.price),
        "priceValidUntil": (Date.current + 1.year).iso8601,
        "availability": "https://schema.org/InStock",
        "itemCondition": "https://schema.org/NewCondition",
        "seller": {
          "@type": "Organization",
          "name": "ARC Duka"
        }
      }
    }

    if product.variants.any?
      data[:offers][:offerCount] = product.variants.count
    end

    data
  end

  def item_list_json_ld(products, name: "Products")
    {
      "@context": "https://schema.org",
      "@type": "ItemList",
      "name": name,
      "itemListElement": products.map.with_index(1) do |product, idx|
        {
          "@type": "ListItem",
          "position": idx,
          "name": product.name,
          "url": product_url(product)
        }
      end
    }
  end
end
