require 'commander/import'
require 'yaml'

program :name, 'Fake data generator'
program :version, '1.0.0'
program :description, 'generador de csv con datos falsos para loyal guru'

PATH_FILES = File.expand_path(File.dirname(File.dirname(__FILE__)))

slug = ask("Slug de la compañia: ")
env = ask("Entorno production/staging: ")
env2 = ask("Vuelve a a escribir el entorno: ")

unless slug.include?('demo')
  raise "Destino no permitido"
end

if env != env2
  raise "Los entornos no coinciden"
end

unless File.exists?('config.yml')
  raise "No se encuentra el fichero de configuración: config.yml"
end

config = YAML.load_file('config.yml')
CONFIG = config[env]

if CONFIG.nil?
  raise "Entorno #{env} no configurado"
end

puts "subiendo a #{env}"

def push(slug, table, headers, file)
  puts "cargando datos... #{file}"

  system("PGPASSWORD=#{CONFIG["password"]} psql -h #{CONFIG["host"]} -U #{CONFIG["user"]} #{CONFIG["database"]} -p #{CONFIG["port"]} -c \"\\copy #{slug}.#{table}(#{headers}) FROM '#{PATH_FILES}/#{file}' DELIMITER ',' CSV HEADER\"")
end

headers = "id, name, company_id"
table = "products"
file = "products.csv"
push(slug, table, headers, file)

headers = ["id", "name", "phone", "email", "created_at", "type"].join(',')
table = "accounts"
file = "accounts.csv"
push(slug, table, headers, file)

headers = ["id","customer_id","code","address","postal_code","city","state","gender","created_at","session","registration_location_id","company_id", "last_activity"].join(',')
table = "profiles"
file = "profiles.csv"
push(slug, table, headers, file)

headers = ["id","code","barcode","session","created_at","day_week","location_id","profile_id","customer_id","total","company_id"].join(',')
table = "activities"
file = "activities.csv"
push(slug, table, headers, file)

headers = ["id", "name", "company_id"].join(',')
table = "locations"
file = "locations.csv"
push(slug, table, headers, file)

headers = ["id", "name", "company_id"].join(',')
table = "locations"
file = "locations.csv"
push(slug, table, headers, file)

headers = ["id", "name", "slug", "origin"].join(',')
table = 'feature_taxonomies'
file = 'feature_taxonomies.csv'
push(slug, table, headers, file)

headers = ["external_id","name","slug","taxonomy_slug"].join(',')
table = "features"
file = 'features.csv'
push(slug, table, headers, file)

headers = ["product_id", "feature_id", "feature_taxonomy_slug"].join(',')
table = "feature_products"
file = 'feature_products.csv'
push(slug, table, headers, file)

Dir.entries("./").keep_if { |entity| entity != '.' && entity != '..' }.each do |file_on|
  if file_on.include?('lines_')

    headers = ["activity_id","activity_code","product_id","product_code","total","company_id"].join(',')
    table = "lines"
    push(slug, table, headers, file_on)
  end
end

