module SoftLayer
  class CLIFormatter
    def self.format(content, format = 'plain', headers = CLI::COLUMNS, output_file = nil)
      send(format.to_sym, content, headers, output_file)
    end

    def self.plain(content, headers, output_file = nil)
      require 'terminal-table'
      table = Terminal::Table.new(headings: headers.map { |c| c.upcase }, rows: content)
      CLISerializer.serialize(table, output_file)
    end

    def self.csv(content, headers, output_file = nil)
      require 'csv'
      csv_str = CSV.generate do |csv|
        csv << headers.map { |c| c.upcase }
        content.each do |row|
          csv << row
        end
      end

      CLISerializer.serialize(csv_str, output_file)
    end

    def self.json(content, headers, output_file = nil)
      json_obj = []
      content.each do |row|
        json_obj << Hash[*headers.zip(row).flatten.compact]
      end

      CLISerializer.serialize(JSON.generate(json_obj), output_file)
    end
  end

  class CLISerializer
    def self.serialize(output, output_file = nil)
      if output_file
        IO.write(output_file, output)
      else
        puts output
      end
    end
  end
end