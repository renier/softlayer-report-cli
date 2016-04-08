require 'softlayer_api'
require 'thor'
require 'softlayer/cli/version'
require 'softlayer/cli/formatter'

class Hash
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
  end
end

module SoftLayer
  class CLI < Thor
    OUTPUT_TYPES = %w[plain csv json]
    COLUMNS = %w[id type hostname ip datacenter cost username name email provision_date]
    OBJECT_MASK =
      'mask[billingItem[cancellationDate,recurringFee,hourlyRecurringFee,'\
        'activeAssociatedChildren[recurringFee,hourlyRecurringFee],'\
        'orderItem[order[userRecord[username,email,firstName,lastName]]]]]'

    desc 'report', 'print a softlayer account report'
    option :username,
      type: :string, desc: 'SoftLayer username', aliases: '-u'
    option :api_key,
      type: :string, desc: 'SoftLayer api key', aliases: '-p'
    option :columns,
      type: :array, desc: 'List of columns to display',
      default: COLUMNS.join(' '), aliases: '-c'
    option :search,
      type: :hash, desc: 'Search filters (e.g. datacenter:wdc01 domain:foobar.com)',
      aliases: '-s'
    option :format,
      type: :string, desc: "Output format",
      default: 'plain', enum: OUTPUT_TYPES, aliases: '-f'
    option :output_file,
      type: :string, desc: 'Path to output file (default: stdout)', aliases: '-o'
    def report
      # Create the softlayer client
      client_opts = {}
      client_opts[:username] = options['username'] if options['username']
      client_opts[:api_key] = options['api_key'] if options['api_key']
      SoftLayer::Client.default_client = SoftLayer::Client.new(client_opts)

      search_opts = options['search'] ? {}.merge(options['search']) : {}
      search_opts.symbolize_keys!
      search_opts[:object_mask] = OBJECT_MASK
      search_opts[:result_limit] = { offset: 0, limit: 150 }

      column_opts = COLUMNS
      column_opts = options['columns'] if options['columns'].is_a? Array

      # Generate table
      rows = []
      %w[BareMetalServer VirtualServer].each do |class_name| # Do for both VMs and physical servers
        loop do
          servers = SoftLayer.const_get(class_name).find_servers(search_opts)
          servers.each do |server|
            # Ignore disconnected servers
            next if server.respond_to?(:status) && server.status == 'DISCONNECTED'
            # Ignore cancelled servers
            cancellation_date = server['billingItem'] && server['billingItem']['cancellationDate']
            next unless cancellation_date.nil? || cancellation_date.strip.empty?

            # Gather column data
            row = []
            row << server.id if column_opts.include? 'id'
            row << class_name if column_opts.include? 'type'
            row << server.fqdn if column_opts.include? 'hostname'
            row << (server['primaryIpAddress'] || server['primaryBackendIpAddress']) if column_opts.include? 'ip'
            row << server['datacenter']['longName'] if column_opts.include? 'datacenter'

            if server['billingItem']
              cost = server['billingItem']['recurringFee'].to_f
              if (server['billingItem']['hourlyRecurringFee'] &&
                  !server['billingItem']['hourlyRecurringFee'].strip.empty?)
                cost = server['billingItem']['hourlyRecurringFee'].to_f * 24 * 30
              end
              server['billingItem']['activeAssociatedChildren'].each do |child|
                if child['hourlyRecurringFee'] && !child['hourlyRecurringFee'].strip.empty?
                  cost += (child['hourlyRecurringFee'].to_f * 24 * 30)
                else
                  cost += child['recurringFee'].to_f
                end
              end
              row << cost.round(2) if column_opts.include? 'cost'

              user_record = server['billingItem']['orderItem']['order']['userRecord']
              row << user_record['username'] if column_opts.include? 'username'
              row << "#{user_record['firstName']} #{user_record['lastName']}" if column_opts.include? 'name'
              row << user_record['email'] if column_opts.include? 'email'
            else # Allow report to continue even when no billing item is found
              row << '' if column_opts.include? 'cost'
              row << '' if column_opts.include? 'username'
              row << '' if column_opts.include? 'name'
              row << '' if column_opts.include? 'email'
            end

            row << server['provisionDate'] if column_opts.include? 'provision_date'

            rows << row
          end

          break if servers.size < search_opts[:result_limit][:limit]
          search_opts[:result_limit][:offset] += search_opts[:result_limit][:limit]
        end
      end

      # Output
      CLIFormatter.format(
        rows,
        options['format'],
        COLUMNS.reject { |c| !column_opts.include?(c) },
        options['output_file']
      )
    end

    desc 'cancel ID ...', 'cancel a softlayer system or systems by ID'
    def cancel(*ids)
      # Create the softlayer client
      client_opts = {}
      client_opts[:username] = options['username'] if options['username']
      client_opts[:api_key] = options['api_key'] if options['api_key']
      SoftLayer::Client.default_client = SoftLayer::Client.new(client_opts)

      problem_ids = []
      done_ids = []
      while ids.size > 0
        server = nil
        begin
          server = SoftLayer::VirtualServer.server_with_id(ids.last)
        rescue
          begin
            server = SoftLayer::BareMetalServer.server_with_id(ids.last)
          rescue
          end
        end

        unless server
          STDERR.puts "No server with id #{id} was found."
          problem_ids << ids.pop
          next
        end

        begin
          server.cancel!
          done_ids << ids.pop
        rescue Exception => e
          STDERR.puts "Error cancelling server #{id}: #{e}"
          problem_ids << ids.pop
        end
      end

      puts "Cancelled #{done_ids.size} servers."
      if problem_ids.size > 0
        puts "Had trouble cancelling servers #{problem_ids.join(', ')}."
        exit 1
      end
    end
  end
end
