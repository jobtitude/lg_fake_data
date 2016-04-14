require 'csv'
require 'ffaker'
require 'commander/import'
require './utils.rb'
require './add_lines.rb'

program :name, 'Fake data generator'
program :version, '1.0.0'
program :description, 'generador de csv con datos falsos para loyal guru'

products = ask("Cantidad de productos: ")
activities = ask("Cantidad de tickets: ")
activities_without_customer = ask("Cantidad de tickets sin cliente: ")
activities_date_from = ask("Inicio fecha de los tickets (aaaa/mm/dd): ")
activities_date_to = ask("Inicio fecha de los tickets (aaaa/mm/dd): ")
customers = ask("Cantidad de clientes: ")
locations = ask("Cantidad de locales: ")
families = ask("Cantidad de familias: ")
company = ask("Identificador de compañia (NO slug): ")

config = {
  products: {
    ids: (1..(products.to_i))
  },

  activities: {
    ids: (1..(activities.to_i)),
    without_customer: (activities_without_customer.to_i),
    dates: {
      from: activities_date_from,
      to: activities_date_to
    }
  },

  locations: {
    ids: (1..(locations.to_i))
  },

  customers: {
    ids: (1..(customers.to_i))
  },

  lines: {

  },

  features: {
    ids: (1..(families.to_i))
  },

  feature_taxonomies: {
    ids: 1
  }
}

COMPANY_ID = company

from = Date.parse(config[:activities][:dates][:from])
to = Date.parse(config[:activities][:dates][:to])
ACTIVITY_DATES  = (from..to).reject{ |d| d.sunday? }.to_a
ACTIVITY_DATES_SIZE = ACTIVITY_DATES.size
ACTIVITY_IDS = config[:activities][:ids]
LOCATIONS = config[:locations][:ids].to_a
LOCATIONS_SIZE = LOCATIONS.size
PRODUCTS = config[:products][:ids].to_a
PRODUCTS_SIZE = PRODUCTS.size
CUSTOMERS = config[:customers][:ids].to_a
CUSTOMERS_SIZE = CUSTOMERS.size
lines = AddLines.new

def potio(ids, line, lines, options = {})
  ids.each do |id|
    session = ACTIVITY_DATES[rand(ACTIVITY_DATES_SIZE)]
    created_at = session.to_s + " #{Utils.random_hour}"
    if options[:without_customers] == true
      profile_id = nil
    else
      profile_id = CUSTOMERS[rand(CUSTOMERS_SIZE)]
    end

    # lines
    lines_num = rand(1..6)
    total_activity = 0

    lines_num.times do |timi|
      total_line = (rand * (20.2) + 2).round(2)
      total_activity += total_line
      product_id = PRODUCTS[rand(PRODUCTS_SIZE)]

      lines.add([id, id, product_id, product_id, total_line, COMPANY_ID])
    end

    #insert activity
    line << [id, id, id, session.to_s,
             created_at.to_s,
             session.wday.to_s,
             LOCATIONS[rand(LOCATIONS_SIZE)],
             profile_id,
             profile_id,
             total_activity,
             COMPANY_ID]

  end
  lines.create_file_with_last_lines
end

CSV.open('activities.csv', 'w') do |line|
  puts 'creando acividades con customer'
  line << ["id","code","barcode","session","created_at","day_week","location_id","profile_id","customer_id","total","company_id"]
  ids = ACTIVITY_IDS
  potio(ids, line, lines)


  puts 'creando acividades sin customer'
  ids = ((ACTIVITY_IDS.last+1)..(ACTIVITY_IDS.last + config[:activities][:without_customer]))
  potio(ids, line, lines, { without_customers: true })
  puts 'end'
end

CSV.open('locations.csv', 'w') do |line|
  line << ["id", "name", "company_id"]
  config[:locations][:ids].each do |id|
    line << [id, FFaker::Address.city, COMPANY_ID]
  end
end

CSV.open('accounts.csv', 'w') do |line|
  line << ["id", "name", "phone", "email", "created_at", "type"]
  phone = FFaker::PhoneNumberDA.phone_number
  config[:customers][:ids].each do |id|
    name = FFaker::Name.name
    email = FFaker::Internet.safe_email
    date = ACTIVITY_DATES[rand(ACTIVITY_DATES_SIZE)].to_s + " #{Utils.random_hour}"
    line << [id, name, phone, email, date, 'Customer']
  end
end

CSV.open('profiles.csv', 'w') do |line|
  line << ["id","customer_id","code","address","postal_code","city","state","gender","created_at","session","registration_location_id","company_id", "last_activity"]
  config[:customers][:ids].each do |id|
    session = ACTIVITY_DATES[rand(ACTIVITY_DATES_SIZE)]
    date = session.to_s + " #{Utils.random_hour}"
    address = FFaker::Address.street_address
    postal_code = FFaker::AddressMX.postal_code
    city = FFaker::Address.city

    line << [id, id, id, address, postal_code, city, 'España', rand(1..2),
             date,
             session,
             LOCATIONS[rand(LOCATIONS_SIZE)],
             COMPANY_ID,
             session
    ]
  end
end

CSV.open('products.csv', 'w') do |line|
  line << ["id", "name", "company_id"]
  config[:products][:ids].each do |id|
    line << [id, FFaker::Product.product_name, COMPANY_ID]
  end
end

CSV.open('feature_taxonomies.csv', 'w') do |line|
  line << ["id", "name", "slug", "origin"]
  line << [1, "Familia", "family", "external"]
end

CSV.open('features.csv', 'w') do |line|
  line << ["external_id","name","slug","taxonomy_slug"]
  config[:features][:ids].each do |id|
    name = FFaker::Product.brand
    line << [id, name, name.downcase, "family"]
  end
end

CSV.open('feature_products.csv', 'w') do |line|
  features = config[:features][:ids].to_a
  features_size = features.size
  line << ["product_id", "feature_id", "feature_taxonomy"]
  config[:products][:ids].each do |id|
    line << [id, features[rand(features_size)], "family"]
  end
end

