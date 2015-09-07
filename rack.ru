require_relative "lib/log_vault"

app = proc do |env|
  resp = Rack::Response.new("", 200, {"Content-Type" => 'text/plain'})
  req = Rack::Request.new(env)

  # If a POST, store the file
  if req.post?
    resp.write(req.params)
    lv = LogVault.new
    lv.destination_format_string = "/tmp/@host"
    lv.save(req.params["logfile"][:tempfile], req.params["logfile"][:filename], req.host)
  else
    resp.write("POST only")
  end
  resp.finish
end

use Rack::CommonLogger

run app
