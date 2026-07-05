module PhoneNormalizer
  def self.normalize(phone, with_plus: true)
    return nil if phone.blank?

    digits = phone.to_s.gsub(/\D/, "")
    
    # Handle 0... format
    if digits.start_with?("0")
      digits = "254#{digits[1..]}"
    end

    # Ensure it starts with 254
    unless digits.start_with?("254")
      digits = "254#{digits}"
    end

    with_plus ? "+#{digits}" : digits
  end
end
