class DiagnosticMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    trace = e.backtrace.select{ |l|l.start_with?(Rails.root.to_s) }.join("\n    ")
    msg = "#{e.class}\n#{e.message}\n#{trace}\n"
    Rails.logger.error msg
    raise e
  end
end
