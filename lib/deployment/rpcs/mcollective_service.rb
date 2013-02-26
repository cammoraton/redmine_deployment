begin
  require 'mcollective'
rescue LoadError => e
  # No mcollective, probably because the stomp gem is absent
end