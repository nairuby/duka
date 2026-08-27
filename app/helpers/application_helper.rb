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
end
