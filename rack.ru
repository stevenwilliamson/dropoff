require_relative "lib/log_vault"

app = proc do |env|
  resp = Rack::Response.new("", 200, {"Content-Type" => 'text/plain'})

  # Trust x-real-ip as we add it in nginx configuration
  if env.has_key?('HTTP_X_REAL_IP')
        env['REMOTE_ADDR'] = env['HTTP_X_REAL_IP']
  end

  req = Rack::Request.new(env)

  # If a POST, store the file
  if req.post?
    lv = LogVault.new
    lv.save(req.params["logfile"][:tempfile], req.params["logfile"][:filename], req.ip)
    resp.write("stored")
  else
    resp.status = 400
    resp.write("POST only with file param named logfile")
  end
  resp.finish
end

use Rack::CommonLogger

run app
