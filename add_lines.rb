class AddLines
  def initialize
    @lines = []
    @lines_total_count = 0
  end

  def add(line)
    @lines << line

    if @lines.size > 100_000
      create_file
    end
  end

  def create_file_with_last_lines
    create_file
  end

  private

  def create_file
    @lines_total_count += 1
    CSV.open("lines_#{@lines_total_count}.csv", 'w') do |activity_line|
      activity_line << ["activity_id","activity_code","product_id","product_code","total","company_id"]
      @lines.each do |line_to_insert|
        activity_line << line_to_insert
      end
    end
    @lines = []
  end

end
