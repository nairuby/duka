xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset(
  "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1"
) do
  # 1. Homepage
  xml.url do
    xml.loc root_url
    xml.changefreq "daily"
    xml.priority "1.0"
  end

  # 2. Products Catalog
  xml.url do
    xml.loc products_url
    xml.changefreq "daily"
    xml.priority "0.9"
  end

  # 3. Categories Index
  xml.url do
    xml.loc categories_url
    xml.changefreq "weekly"
    xml.priority "0.8"
  end

  # 4. Each Product Category
  @categories.each do |cat|
    xml.url do
      xml.loc category_url(cat)
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  # 5. Static Pages
  xml.url do
    xml.loc landing_about_url
    xml.changefreq "monthly"
    xml.priority "0.7"
  end

  xml.url do
    xml.loc new_contact_message_url
    xml.changefreq "monthly"
    xml.priority "0.6"
  end

  # 6. Active Products
  @products.each do |product|
    xml.url do
      xml.loc product_url(product)
      xml.lastmod product.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.8"
      if product.image_url.present?
        xml.tag!("image:image") do
          xml.tag!("image:loc", product.image_url)
          xml.tag!("image:title", product.name)
          xml.tag!("image:caption", product.description.presence || product.name)
        end
      end
    end
  end
end
