module ApplicationHelper
  def arc_social_media_links
    [
      {
        platform: "twitter",
        icon: "fa-twitter",
        url: "https://x.com/ruby_african"
      },
      {
        platform: "instagram",
        icon: "fa-instagram",
        url: "https://www.instagram.com/africanruby_community"
      },
      {
        platform: "linkedin",
        icon: "fa-linkedin",
        url: "https://www.linkedin.com/company/african-ruby-community"
      },
      {
        platform: "youtube",
        icon: "fa-youtube",
        url: "https://www.youtube.com/@nairubyorg7626"
      },
      {
        platform: "github",
        icon: "fa-github",
        url: "https://github.com/nairuby"
      }
    ]
  end

  def format_price(amount)
    currency = Current.currency || "KES"

    # Assuming base price is always in KES as per product seeds
    converted_amount = CurrencyConverter.convert(amount, "KES", currency)

    number_to_currency(converted_amount, unit: currency + " ", precision: 2)
  end

  # Open Graph / Twitter Card tags for link previews. Called with no args in
  # the layout for a sensible site-wide default; pages override via
  # `content_for(:head) { og_meta_tags(...) }` (see products/show.html.erb).
  def og_meta_tags(title: nil, description: nil, image: nil, type: "website")
    title       ||= "ARC Duka"
    description ||= "Quality merchandise from Ruby Community Africa."
    image       ||= asset_url("arc_logo_coloured.png")

    safe_join([
      tag.meta(property: "og:title", content: title),
      tag.meta(property: "og:description", content: description),
      tag.meta(property: "og:image", content: image),
      tag.meta(property: "og:type", content: type),
      tag.meta(property: "og:url", content: request.original_url),
      tag.meta(name: "twitter:card", content: "summary_large_image"),
      tag.meta(name: "twitter:title", content: title),
      tag.meta(name: "twitter:description", content: description),
      tag.meta(name: "twitter:image", content: image)
    ])
  end
end
