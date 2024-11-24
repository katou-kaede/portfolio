Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://script.google.com/macros/s/AKfycbxjzuWLndE-WC9ziRfqKhwIWkkrZ4mFGj03LfeztHMpdPq5v3u2DrXEF7TAZuu9QI-f-w/exec"
    resource "*", headers: :any, methods: [ :get, :post, :options ]
  end
end
