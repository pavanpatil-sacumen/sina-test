class HostAuthorization
  def initialize(app, allowed_hosts)
    @app = app
    @allowed_hosts = allowed_hosts
  end

  def call(env)
    request_host = env['HTTP_HOST']
    if @allowed_hosts.include?(request_host)
      @app.call(env)
    else
      [403, { 'Content-Type' => 'text/plain' }, ['Host not permitted']]
    end
  end
end
