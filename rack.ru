require_relative "lib/log_vault"

app = proc do |env|
  resp = Rack::Response.new("", 200, {"Content-Type" => 'text/plain'})
  req = Rack::Request.new(env)

  # If a POST, store the file
  if req.post?
    lv = LogVault.new
    lv.save(req.params["logfile"][:tempfile], req.params["logfile"][:filename], req.host)
    resp.write("stored")
  else
    resp.write("POST only with file param named logfile")
  end
  resp.finish
end

use Rack::CommonLogger

run app
