desc 'Add, remove and list config for an app'
command :config do |c|
  c.default_desc 'List all config'
  c.action do |_global_options, _options, _args|
    @api.request :get, "/app/#{Git.name_from_remote}/config"
  end

  c.desc 'Delete config by keys'
  c.command :rm do |sc|
    sc.action do |_global_options, _options, args|
      @api.request(
        :delete,
        "/app/#{Git.name_from_remote}/config",
        keys: args.to_json
      )
    end
  end

  c.desc 'Set config for an app'
  c.command :set do |sc|
    sc.action do |_global_options, _options, args|
      if args.length == 0
        exit_now! "Please provide config in the form: FOO=BAR ENV=production"
      end
      vars = {}
      args.each do |arg|
        parts = arg.split('=', 2)
        key = parts[0]
        value = parts[1]
        vars[key] = value
      end
      @api.request(
        :put,
        "/app/#{Git.name_from_remote}/config",
        vars: vars.to_json
      )
    end
  end
end
