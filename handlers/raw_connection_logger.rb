class RawConnectionLogger < Marvin::Base

  on_event :client_connected, :setup_logging
  on_event :reloaded, :setup_logging

  on_event :client_disconnected, :teardown_logging
  on_event :reloaded, :teardown_logging

  @@files = {}

  def setup_logging
    logger.info "Setting up logging"
    @@files[client.host_with_port] = nil
    self.file # Access the ivar to load it
  end

  def teardown_logging
    logger.info "Stopping logging"
    if @@files[client.host_with_port].present?
      @@files[client.host_with_port].puts ""
      @@files[client.host_with_port].close
      @@files.delete client.host_with_port
    end
  end

  on_event :incoming_line do
    log_line true
  end

  on_event :outgoing_line do
    log_line false
  end

  def log_line(incoming = true)
    color = incoming ? :green : :blue
    prefix = incoming ? "<< " : ">> "
    file.puts Marvin::ANSIFormatter.format(color, "#{prefix}#{options.line}".strip)
  end

  def file
    @@files[client.host_with_port] ||= begin
      logger.info "Loading Logger..."
      uri = URI.parse("irc://#{client.host_with_port}")
      log_path = File.join(Marvin::Settings.root, "log", "connections", "#{uri.host}-#{uri.port}-#{Time.now.to_i}.log")
      logger.info "Logging to #{log_path}"
      FileUtils.mkdir_p(File.dirname(log_path))
      file = File.open(log_path, "a+")
      file.sync = true if file.respond_to?(:sync=)
      file
    end
  end

end