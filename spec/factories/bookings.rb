FactoryBot.define do
  factory :booking do
    ticket_number { rand(1_000_000..9_999_999) }
    booking_number { rand(1000..9999) }
    booking_date { Faker::Date.backward(days: 14) }
    booking_hour { "#{rand(8..20)}:00" }

    event_key { "EVT#{rand(1000..9999)}" }
    event { Faker::Music.band }

    show_key { "SHW#{rand(1000..9999)}" }
    show { "#{event} - #{Faker::Music.album}" }
    show_date { Faker::Date.forward(days: 7) }
    show_hour { "20:00" }
    show_end_date { show_date }
    show_end_hour { "22:00" }

    price { Faker::Commerce.price(range: 10.0..100.0) }
    product_type { [ "Billet standard", "Billet VIP" ].sample }
    sales_channel { [ "Online", "Guichet", "Téléphone" ].sample }

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }

    address { Faker::Address.street_address }
    postal_code { Faker::Address.postcode }
    country { Faker::Address.country }

    age { rand(18..80) }
    gender { [ "F", "M" ].sample }
  end
end
